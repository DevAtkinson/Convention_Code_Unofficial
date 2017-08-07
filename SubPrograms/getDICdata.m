function [out] = getDICdata(filepath,filename)
%GETDICDATA     Loads displacment field from LaVision .dat files.
%   [posXdic,posYdic,posZdic,uXdic,uYdic,uZdic] = GETDICDATA(imgno)
%   obtaines the positonal (pos) and displacement (u) data from LaVision
%   DIC data for a filename format of B0000#. imgno is the data file number
%   to be loaded.
%
%   fmt can be .txt or .dat - but .dat is the default (use Tecplot in DaVis
%   export)

% fprintf('Loading field from %s...', filename)

if exist('filepath','var')
    addpath(filepath)
end
% Load data according to LaVision convention: B00__#.dat.
% filename = sprintf('B%3.5d.dat', imgno);                                    
filedata = importdata(filename);                                        
filedata = sortrows(filedata.data,1);%/1000;

if size(filedata,2) == 4;
    posXdic = filedata(:,1);
    posYdic = filedata(:,2);
    posZdic = zeros(size(posXdic));
    uXdic = filedata(:,3);
    uYdic = filedata(:,4);
    uZdic = zeros(size(uXdic));
elseif size(filedata,2) == 6;
    posXdic = filedata(:,1);
    posYdic = filedata(:,2);
    posZdic = filedata(:,3);
    uXdic = filedata(:,4);
    uYdic = filedata(:,5);
    uZdic = filedata(:,6);
else
    error('DIC could not be read.');
end

%save data to structure array


if exist('filepath','var')
    rmpath(filepath)
end

% fprintf('done.\n')

[field,headers]=fieldformat(posXdic,posYdic,posZdic,uXdic,uYdic,uZdic,'gridspace','regular');
[uX,uY,uZ]=field2grid(field,headers,'ux','uy','uz');
[posX,posY,posZ]=field2grid(field,headers,'posx','posy','posz');



out=struct('PosX',posX,'PosY',posY,'PosZ',posZ,'uX',uX,'uY',uY,'uZ',uZ);
end

function [varargout] = fieldformat(posX,posY,posZ,uX,uY,uZ,varargin)
%FIELDFORMAT Formats input data into required field format.
%   [field,headers,gridspace] = FIELDFORMAT(posX,posY,posZ,uX,uY,uZ) stores
%   input data in column vectors arranged in a defined header order.
%   FIELDFORMAT requires inputs posX (node position in x), posY (node
%   position in y), posZ (node position in z), uX (node displacement in x),
%   uY (node displacement in y), uZ (node displacement in z). posZ may be
%   set to zero (posz = 0) if posz data is not available. If posX and posY
%   is not regular, FIELDFORMAT will interpolate data (linearly) to
%   regularise data.
%
%   field is stored as:
%       field(:,1)   'node_nums'     node numbers stored in field
%       field(:,2)   'mask'          node number mask
%       field(:,3)   'posx'          node position in x
%       field(:,4)   'posy'          node position in y
%       field(:,5)   'posz'          node position in z
%       field(:,6)   'uxx'           node displacement in xx direction
%       field(:,7)   'uyy'           node displacement in yy direction
%       field(:,8)   'uzz'           node displacement in zz direction
%
%   [field] = FIELDFORMAT(posX,posY,posZ,uX,uY,uZ,'gridspace',gridoption)
%   defines the grid space of field. If gridoption is not definied, the
%   grid spacing is set to gridoption = 0.001 as a default. gridoption may
%   be defind as
%       #value          FIELDFORMAT interpolates data at #value intervals
%                       in x and y direction.
%       'regular'       Assumes gridded data. Grid spacing is calculated
%                       based on unique position pairs.
%       'irregular'     Defines the grid spacing based on the number of
%                       nodes and the surface area.
%
%   [field] = FIELDFORMAT(posX,posY,posZ,uX,uY,uZ,'rotate',theta) rotates
%   data by angle theta (in radians).
%
%   [field] = FIELDFORMAT(posX,posY,posZ,uX,uY,uZ,'shiftpos',[posx posy
%   posz]) shifts position data so that zero position is at [posx posy posz].
%
%   [field] = FIELDFORMAT(posX,posY,posZ,uX,uY,uZ,'shiftdisp',[posx posy
%   posz]) shifts displacment data so that [ux uy uz] = 0 at [posx posy
%   posz].

warning off
% fprintf('Formating data...')

% Check if varargin has been given in pairs
nArgs = length(varargin);
if round(nArgs/2) ~= nArgs/2
    error('FORMATDATA needs propertyName/propertyValue pairs')
end
% Reshape varargin into 2xn matrix, [options; variable] pairs
vararginpair = reshape(varargin,2,[]);

% Default field headers
headers = {'node_num','mask','posx','posy','posz','ux','uy','uz'};

% Foramt input data.
posx = posX(:);
posy = posY(:);
ux = uX(:);
uy = uY(:);
if (sum(sum(abs(posZ))) == 0)&&(sum(sum(abs(uZ))) == 0)
    posz = zeros(length(posx),1);
    uz = posz;
else
    posz = posZ(:);
    uz = uZ(:);
end

% Loop through all input options. Note, order is relevant.
% Set defaults: %^&* Matt: so that no varargin works.
shiftdisp = [0,0,0];
shiftpos = [0,0,0];
theta = 0;
gridoption = 0.02*abs(max(posx)-min(posx));

for i = 1:length(vararginpair)
    % Determine gridsapce
    %         fov = [range(posx), range(posy), range(posz)];
    fov = [(max(posx)-min(posx)),(max(posy)-min(posy)),(max(posz)-min(posz))];
    if find(strcmp('gridspace',vararginpair(1,:))) == 1
        [~, pos] = find(strcmp('gridspace',vararginpair(1,:)));
        gridoption = vararginpair(2,pos);
        % Detirmine gridsapce option
        if isnumeric(gridoption{:})
            gridoption = gridoption{:};
            
        else
            switch gridoption{1}
                case {'regular'}
                    % Calculate grid option for regular data (DIC, etc)
                    linx = length(unique(posx));
                    gridoption = fov(1)/(linx-1);
                case {'irregular'}
                    % Calculate grid option for irregular data (FEM, etc)
                    gridoption = sqrt((fov(1)*fov(2))./length(posx(:)));
                    % Other options go here
                otherwise
                    error(['Invalid gridspace argument, ',gridoption{1}]);
            end
        end
        % Delete varargin pair
        vararginpair(:,pos) = [];
    end
    % Rotate position and displacement data
    if find(strcmp('rotate',vararginpair(1,:))) == 1
        [~, pos] = find(strcmp('rotate',vararginpair(1,:)));
        theta = vararginpair(2,pos);
        theta = theta{:};
        vararginpair(:,pos) = [];
    end
    % Shift position data
    if find(strcmp('shiftpos',vararginpair(1,:))) == 1
        [~, pos] = find(strcmp('shiftpos',vararginpair(1,:)));
        shiftpos = vararginpair(2,pos);
        shiftpos = shiftpos{:};
        [~,ind] = min(abs([posx,posy,posz]-ones(length(posx),1)*shiftpos),[],1);
        shiftpos = [posx(ind(1)),posy(ind(2)),posz(ind(3))];
        vararginpair(:,pos) = [];
    end
    % Average displacement data
    if find(strcmp('shiftdisp',vararginpair(1,:))) == 1
        [~, pos] = find(strcmp('shiftdisp',vararginpair(1,:)));
        shiftdisppos = vararginpair(2,pos);
        shiftdisppos = shiftdisppos{:};
        [~,ind] = min(bsxfun(@minus,[posx,posy,posz],shiftdisppos).^2*ones(3,1),[],1);
        shiftdisp = [ux(ind),uy(ind),uz(ind)];
        vararginpair(:,pos) = [];
    end
end

% Adjust position data: shift then rotate
posxc = (posx-shiftpos(1)).*cos(theta) - (posy-shiftpos(2)).*sin(theta);
posyc = (posx-shiftpos(1)).*sin(theta) + (posy-shiftpos(2)).*cos(theta);
poszc =  posz-shiftpos(3);
% Adjust disp data
uxc = (ux-shiftdisp(1))*cos(theta) - (uy-shiftdisp(2))*sin(theta);
uyc = (ux-shiftdisp(1))*sin(theta) + (uy-shiftdisp(2))*cos(theta);
uzc = uz-shiftdisp(3);
% Generate gridded data...
minx =  ceil(min(posxc)/gridoption);
maxx = floor(max(posxc)/gridoption);
miny =  ceil(min(posyc)/gridoption);
maxy = floor(max(posyc)/gridoption);
gridlinx = minx*gridoption:gridoption:maxx*gridoption;
gridliny = miny*gridoption:gridoption:maxy*gridoption;
[posX,posY] = meshgrid(gridlinx,gridliny);
field = zeros(numel(posX),8);
field(:,1) = 1:numel(posX);
field(:,2) = ones(numel(posX(:),1));
field(:,3) = posX(:);
field(:,4) = posY(:);
method='linear';
posZ = griddata(posxc,posyc,poszc,posX,posY,method);
uX   = griddata(posxc,posyc,uxc  ,posX,posY,method);
uY   = griddata(posxc,posyc,uyc  ,posX,posY,method);
uZ   = griddata(posxc,posyc,uzc  ,posX,posY,method);
field(:,5) = posZ(:);
field(:,6) = uX(:);
field(:,7) = uY(:);
field(:,8) = uZ(:);
% Set NaN values to zero
field(isnan(field)) = 0;
% Write output variables
varargout{1} = field;
varargout{2} = headers;
varargout{3} = gridoption;
% fprintf('done.\n')
warning on
end

function [varargout] = field2grid(field, headers, varargin)
%DATA2GRID  Formats field into gridded data.
%   [varargout] = DATA2GRID(field, headers, varargin) outputs field data
%   into meshgrid format. Any field headers may be called.
%
%   Standard  headers are:
%       'node_nums'     node numbers stored in field
%       'mask'          mode mask value
%       'posx'          node position in x
%       'posy'          node position in y
%       'posz'          node position in z
%       'ux'           node displacment in xx direction
%       'uy'           node displacment in yy direction
%       'uz'           node displacment in zz direction
%
%   For example, [posX,posY] = DATA2GRID(field, headers, 'posx','posy')
%   gives the gridded data for gridded data for node position in x and node
%   position in y stored in field.
%
%   Note: DATA2GRID assumes that all data is in the field format (see
%   FIELDFORMAT)

% fprintf('Gridding field...')
% Determine datasize = [row, col]
[linx, liny] = getsize(field);

% Call field data to output gridded data

for c=1:length(varargin)
    [~, pos] = find(strcmp(varargin{c},headers));
    if isempty(pos)
        varargout{c}=['Variable ',varargin{c},' has not yet been added to FIELD']; %save this text to missing variable. %^&* Matt
        disp(' ')
        disp(varargout{c})
    else
        varargout{c} = reshape(field(:,pos),linx,liny);
    end
end


% fprintf('done.\n')
end

function [varargout] = getsize(varargin)
% GETSIZE   Determines the size [row col] of field data.
%   [row col] = getsize(field) determines the size of field as the number
%   of rows and columns. This is useful when using reshape function.
% 
%   [row col sz] = getsize(field) determines the size in z as well.
% 
% getsize can use arrays or column vectors as inputs as well,
% e.g.
% [row col sz]=getsize(field(:,3),field(:,4),field(:,5));




if nargin==1
    field=varargin{1};
    posx=field(:,3);
    posy=field(:,4);
    posz=field(:,5);
elseif nargin>=2
    posx=varargin{1};
    posy=varargin{2};
    posx=posx(:); %just incase its an array
    posy=posy(:);
    if nargin==3
        posz=varargin{3};
        posz=posz(:);
    else
        posz=[0];
    end
end

linx=unique(posx);
liny=unique(posy);
linz=unique(posz);

varargout{1} = length(liny);
varargout{2} = length(linx);
varargout{3} = length(linz);

end
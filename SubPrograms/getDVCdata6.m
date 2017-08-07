function [field_out,gridspacing]=getDVCdata6(filename,indir)
% Also works perfectly for 3D DIC data (needs 6 columns in indir .dat files)
% fileheader='B';
% numZeros=5;
% sprint_im=['%0' int2str(numZeros) 'd'];
% filename=[fileheader, sprintf(sprint_im,imno),'.dat'];

% disp(['loading DVC dataset: ',filename]);

% add a '\' to the end of the path if it doesn't exist:
if ispc
    if ~exist('indir','var')
        indir=[];
    elseif ~strcmp(indir(end),'\')
        indir=[indir,'\'];
    end
elseif isunix
    if ~exist('indir','var')
        indir=[];
    elseif ~strcmp(indir(end),'/')
        indir=[indir,'/'];
    end
end

temp=importdata([indir,filename]);

%% sort data into meshgrid order
tempd=temp.data;
try
    pos= tempd(:,1:3);
    u  = tempd(:,4:6);
catch
    nul=zeros(size(tempd,1),1);
    pos= [tempd(:,1:2),nul];
    u  = [tempd(:,3:4),nul];
    warning on
    warning('2D data assumed')
end

% [~,id]=unique(tempd(:,1:3),'rows'); %
% pos= tempd(id,1:3);
% u  = tempd(id,4:6);

% % subtract rigid body motion:
% goodID=sum(abs(u),2);
% goodID=logical(goodID);
% rbm=mean(u(goodID,:));
% u(goodID,:)  = u(goodID,:)-repmat(rbm,size(u(goodID,:),1),1);



%% round off grid positions to grid spacing:
gridspacing = abs(median(gradient(pos(:,1))));

minpos=repmat(min(pos),size(pos,1),1); % round off the values
pos=round((pos-minpos)/gridspacing)*gridspacing+minpos;

%% put together field
field=[pos,u];
[~,sort4grid]=sortrows(pos,[3,1,2]);
field=field(sort4grid,:);

field_out=field2grid_vec(field,'dvc');
end

function [FIELD] = field2grid_vec(field,str)
% also works for 3D DIC (doesn't work for 2D dic yet).
% if str is 'dic' then assumes 3D stereo DIC
% fprintf('gridding fields...\n')

    if ~exist('str','var')
        str='dvc';
    end

    if strcmp(str,'dvc')
        a=length(unique(field(:,1)));
        b=length(unique(field(:,2)));
        c=length(unique(field(:,3)));
        
        field=sortrows(field,[3,1,2]); %^&* KEY
        datasize=[b,a,c];
        % % dataorder=[b,c,a];
        % dataorder=[c,a,b];
        
        POSX= reshape(field(:,1),datasize);
        POSY= reshape(field(:,2),datasize);
        POSZ= reshape(field(:,3),datasize);
        UX  = reshape(field(:,4),datasize);
        UY  = reshape(field(:,5),datasize);
        UZ  = reshape(field(:,6),datasize);
        
        FIELD.PosX=POSX;
        FIELD.PosY=POSY;
        FIELD.PosZ=POSZ;
        FIELD.uX=UX;
        FIELD.uY=UY;
        FIELD.uZ=UZ;
    else
        a=length(unique(field(:,1)));
        b=length(unique(field(:,2)));
        
        field=sortrows(field,[1,2]); %^&* KEY
        datasize=[b,a,c];
        % % dataorder=[b,c,a];
        % dataorder=[c,a,b];
        
        POSX= reshape(field(:,1),datasize);
        POSY= reshape(field(:,2),datasize);
        POSZ= reshape(field(:,3),datasize);
        UX  = reshape(field(:,4),datasize);
        UY  = reshape(field(:,5),datasize);
        UZ  = reshape(field(:,6),datasize);
        
        FIELD.PosX=POSX;
        FIELD.PosY=POSY;
        FIELD.PosZ=POSZ;
        FIELD.uX=UX;
        FIELD.uY=UY;
        FIELD.uZ=UZ;
    end
% fprintf('done\n')
end

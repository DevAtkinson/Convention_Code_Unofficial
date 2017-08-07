function [fieldfem,crackfem]=getFEMdata7(filename,reload,mask_ranges)
%Requiresthatfilesexistwithtitles:
%[filename,'_fields.txt']withalltheoutputfieldsin.
%[filename,'_nodes.txt']withalltheoutputnodes.
%[filename,'.dat']withfractureoutputdata.
% idmask[xmin xmax ymin ymax zmin zmax] where nans mean full range

%     split filepath into path and name to be saved:
slashes=regexp(filename,'\');
lastslash=slashes(end);
savepath=filename(1:lastslash-1);
savename=filename(lastslash+1:end);



if nargin==1
    reload=2;
end

if nargin<3
    mask_ranges=[nan,nan,nan,nan,nan,nan];
end

if reload==1
    fprintf('Loading%s...\n',filename)
    
    %import fem node co-ordinates
    disp('loading FEM nodes');
    choose_file=[filename,'_nodes.txt'];
    nodes=importdata(choose_file);
    posxtemp=nodes(:,2);
    posytemp=nodes(:,3);
    posztemp=nodes(:,4);
    
    % set nan's to full range
    for ii=1:length(mask_ranges)
        if isnan(mask_ranges(ii))
            if rem(ii,2)
                mask_ranges(ii)=-1e16;
            else
                mask_ranges(ii)=+1e16;
            end
        end
    end
    mask_ranges=sort(reshape(mask_ranges,2,3));mask_ranges=mask_ranges(:); % make sure it goes from small to big
    % create mask
    if ~isnan(sum(mask_ranges))
        maskall=(posxtemp>mask_ranges(1))&(posxtemp<mask_ranges(2))&(posytemp>mask_ranges(3))&(posytemp<mask_ranges(4))&((posztemp>mask_ranges(5))&(posztemp<mask_ranges(6)));
    end
    
    nodes=nodes(maskall,:);
    fieldfem.nodes=nodes(:,1);
    fieldfem.POSX=nodes(:,2);
    fieldfem.POSY=nodes(:,3);
    fieldfem.POSZ=nodes(:,4);
    
    % import field values
    disp('importing FEM field values');
    choose_file=[filename,'_fields.txt'];
    fields=importdata(choose_file);
    headersfem=fields.colheaders;
    fields=fields.data;
    fields=fields(maskall,:); %mask data
    
    allfemheaders={'Node','Mask','POS.POS1','POS.POS2','POS.POS3','U.U1','U.U2','U.U3','E.E11','E.E22','E.E33','E.E12','E.E13','E.E23','S.S11','S.S22','S.S33','S.S12','S.S13','S.S23','SENER','CF.CF1','CF.CF2','CF.CF3','RF.RF1','RF.RF2','RF.RF3'};
    myheaders={'nodes','MASK','POSX','POSY','POSZ','UX','UY','UZ','EXX','EYY','EZZ','EXY','EXZ','EYZ','SXX','SYY','SZZ','SXY','SXZ','SYZ','W','CFX','CFY','CFZ','RFX','RFY','RFZ'};
    
    headersfemout=headersfem;
    for ii=1:length(headersfem)
        headi=headersfem{ii};
        abin=strcmpi(allfemheaders,headi);
        numi=find(abin);
        if ~isempty(numi)
            fieldfem.(myheaders{numi})=fields(:,ii);
            headersfemout{ii}=myheaders{numi};
        end
    end
    
    try % change to tensor strain
        fieldfem.EXY=fieldfem.EXY/2;
        fieldfem.EXZ=fieldfem.EXZ/2;
        fieldfem.EYZ=fieldfem.EYZ/2;
    catch
        disp('strain fields were not available.')
    end
    
    
    
    % material properties
    disp('importing FEM material properties');
    matprops=getEv_fif(filename);
    fieldfem.E=matprops(1);%^&*assumes[mm]
    fieldfem.v=matprops(2);
    
    if(sum(nodes(:,1))~=sum(fields(:,1)))
        error('You didn''t copy the same number of lines from nodes and fields')
    end
    
%     gridspacing1=getgridoption(fieldfem.POSX,fieldfem.POSY,fieldfem.POSZ);
%     gridspacing2=getgridoption(fieldfem.POSZ);
    fieldfem.gridspacing='irregular';
    
    % import crack
    if nargout==2
        disp('importing FEM crack properties');
        choose_file=filename;
        crackfem=getFEMCRACKall6(choose_file);
        % Get J values
        dispiftrue(pwd,'plane_strain assumed here.')
        [crackfem.JI,crackfem.JII,crackfem.JIII] = k2j('plane_stress',crackfem.KI,crackfem.KII,crackfem.KIII,fieldfem.E,fieldfem.v);
        % bigdatasaver(savepath,savename,fieldfem,crackfem)
    else
        % bigdatasaver(savepath,savename,fieldfem)
        crackfem=['was not saved in ',pwd];
        disp('(skipped importing FEM crack properties)');
    end
    
    
    
    
    
    disp('FEM data was reloaded and saved')
elseif reload==2
    try
        loadpath=bigdatasaver(savepath,savename);
        load(loadpath);
        disp('FEM data was reloaded')
    catch
        warning on
        warning(['Data did not exist - had to reload again. Check directory: ',loadpath])
        reload=1;
        [fieldfem,crackfem]=getFEMdata7(filename,reload);
    end
else
    disp('FEM data was skipped (files should be the same)')
end

end



function[matprops]=getEv_fif(filename)
%CanextractEandvfromthe.inpfilewithfilename
%returnsinmatpropsasa1x2array[E,v]

fid=fopen([filename,'.inp'],'r');
allstr=textscan(fid,'%s',1e12,'Delimiter','\n');
allstr=allstr{1};

firstword='*Elastic';
logical_row=strncmpi(allstr,firstword,size(firstword,2));
row=find(logical_row);
str=allstr(row+1,:);
str=str{1};%turnsitintoastringfromacell...
matprops=str2num(str);

end
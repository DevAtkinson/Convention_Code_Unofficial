function [FIELD,FIELDdavis]=getVC7data2D(filename,pathvc7)
% NB: GETVC7DATA only works if the folder 'readimxstuff' is in the matlab search path.
% 
% GETVC7DATA Fetches all possible fields in a particular davis file DAVIS_FILE_NUMBER located at
% PATHVC7. If PATHVC7 is not specified, then .vc7 files are assumed to be
% in the current working directory.
% Outputs are in the structure format with slightly shorter names:
% FIELD is the structure format using these e.g. (UX,POSX,gridspacing...)
% FIELDdavis is a structure containing the original DaVis field names,
% but with colons ':' and white space ' ' replaced by '__'
% and '_' respectively.
% 
% e.g.
% [FIELD,FIELDdavis]=getVC7data(2,'C:\Users\Matt\Downloads');
%
% Note: New field names (e.g. that might result from a new version of DaVis)
% are currently added with the prefix 'UNEXPECTED_FIELD_' followed by the default
% DaVis field name.
% e.g. If a DaVis field existed called: 'TS:Height of clouds'
% Then you will find it under: FIELD.UNEXPECTED_FIELD__TS__Height_of_clouds
% or in the DaVis structure: FIELDdavis.TS__Height_of_clouds


if ~exist('pathvc7','var')
    pathvc7=pwd;
end

if ~exist('filename','var')
    davis_file_number=1;
    sprint_im=['%0' int2str(5) 'd'];
    filename=['\B', sprintf(sprint_im, davis_file_number),'.vc7']; % change to .txt if the davis output is a text file
end

%% read Davis data into Matlab
% sprint_im=['%0' int2str(5) 'd'];
% filename=['\B', sprintf(sprint_im, davis_file_number),'.vc7']; % change to .txt if the davis output is a text file

% disp(['~ loading DVC dataset: ',filename]);
B = readimx([pathvc7,filename]);
F = B.Frames{1}; % Frame 1



for ii=1:length(F.ComponentNames)
    headeri=F.ComponentNames{ii};
    try
        fieldi=put_together_fif(F,headeri);
        headeri = strrep(headeri,' ','_');
        headeri = strrep(headeri,':','__');
        FIELDdavis.(headeri) = fieldi;
    catch
        disp(['~ could not get: ',headeri])
    end
    
end


% Fix up displacements:
datasize=size(FIELDdavis.U0);
divg=2;
if length(datasize)==3
    [POSX,POSY,POSZ]=meshgrid(0:datasize(2)-1,0:datasize(1)-1,0:datasize(3)-1);
    gridspacing=getgridspacing_DVC_fif(F);
    POSX=POSX*gridspacing + gridspacing/divg;
    POSY=POSY*gridspacing + gridspacing/divg;
    POSZ=POSZ*gridspacing + gridspacing/divg;
    % Scale up z
    zscale= F.Scales.Z.Slope;
    
elseif length(datasize)==2
    [POSX,POSY]=meshgrid(0:datasize(2)-1,0:datasize(1)-1);
    gridspacing=getgridspacing_DIC_fif(F);
    POSX=POSX*gridspacing + gridspacing/divg;
    POSY=POSY*gridspacing + gridspacing/divg;
    POSZ=POSY*0;
    % Scale up z
    zscale=abs(F.Scales.X.Slope);
end


% add basic fields
FIELD.POSX=POSX;
FIELD.POSY=POSY;
FIELD.POSZ=POSZ;
FIELD.gridspacing=gridspacing;
FIELD.datasize=datasize;

% try adding the rest of the fields
davis_headers=fieldnames(FIELDdavis);
for ii=1:length(davis_headers)
    headershort=changeHeader2shortConvention_fif(davis_headers{ii});
    try
        scale_field=1;
        setzero2=0;
        switch headershort(1:2)
            case 'UX'
                scale_field=F.Scales.X.Slope;
                setzero2=nan;
            case 'UY'
                scale_field=F.Scales.Y.Slope;
                setzero2=nan;
            case 'UZ'
                scale_field=zscale;
                setzero2=nan;
        end
        tempi=FIELDdavis.(davis_headers{ii})*scale_field; % scale (if a displacement field)
        tempi(tempi==0)=setzero2; % set zeros to nans (if a displacement field)
        FIELD.(headershort)=tempi;
    catch
        dispiftrue(true,['~ eish - there was a problem with ',davis_headers{ii}],pwd)
    end
end

FIELD=orderfields(FIELD);
FIELDdavis=orderfields(FIELDdavis);
end


function [vc7field]=put_together_fif(F,str)

% Extract displacement fields
idx=find(strcmpi(F.ComponentNames,str));
sizedisp=[size(F.Components{idx}.Planes{1}),length(F.Components{idx}.Planes)];

vc7field=nan(sizedisp);

for ii=1:length(F.Components{idx}.Planes);
    vc7field(:,:,ii)=F.Components{idx}.Planes{ii};
end

vc7field=permute(vc7field,[2,1,3]);
vc7field=vc7field(end:-1:1,:,:);

end

function gridspacing=getgridspacing_DIC_fif(F)
% fetches gridspacing after checking that it is equal in <x,y,z>
% directions.
gridspacing_xyz=[F.Scales.X.Slope*F.Grids.X,F.Scales.Y.Slope*F.Grids.Y]; % get X y z gridspacings
gridspacing_xyz=abs(gridspacing_xyz);
if min(gridspacing_xyz)==max(gridspacing_xyz)
    gridspacing=gridspacing_xyz(1);
else
    error('~ davis gridspacing directions are not equal (we do not support this in our code), check correlation settings (did you set expand in z?)')
end
end

function gridspacing=getgridspacing_DVC_fif(F)
% fetches gridspacing after checking that it is equal in <x,y,z>
% directions.
gridspacing_xyz=[F.Scales.X.Slope*F.Grids.X,F.Scales.Y.Slope*F.Grids.Y,F.Scales.Z.Slope*F.Grids.Z]; % get X y z gridspacings
gridspacing_xyz=abs(gridspacing_xyz);
if min(gridspacing_xyz)==max(gridspacing_xyz)
    gridspacing=gridspacing_xyz(1);
else
    error('~ davis gridspacing directions are not equal (we do not support this in our code), check correlation settings (did you set expand in z?)')
end
end

function [headershort]=changeHeader2shortConvention_fif(headerDavis)
% Change to short's naming convention:
% UXm1 is UX from the analysis minus 1 from the end.
% Where the final value is ('U0' in the DaVis convention) is the one you
% want.

davisConvention={'U0'
    'V0'
    'W0'
    'U1'
    'V1'
    'W1'
    'U2'
    'V2'
    'W2'
    'U3'
    'V3'
    'W3'
    'U4'
    'V4'
    'W4'
    'U5'
    'V5'
    'W5'
    'ACTIVE_CHOICE'
    'ENABLED'
    'TS__Peak_ratio'
    'MASK'
    'TS__Confidence_region'
    'TS__Correlation_value'
    'TS__Exx'
    'TS__Exy'
    'TS__Eyx'
    'TS__Eyy'
    'TS__Vector_status'
    'TS__Fraction_of_valid_voxel_1'
    'TS__Fraction_of_valid_voxel_2'
    'TS__Time_for_prepare_and_peak'
    'TS__Time_for_correlation'
    'TS__Height'
    'TS__Stereo_reconstruction_error'
    'TS__Surface_height_reconstruction_error'
    'TS__Height_of_deformed_image'
    'TS__Height_of_deformed_image_mask'};

mattConvention={'UX'
    'UY'
    'UZ'
    'UXm1'
    'UYm1'
    'UZm1'
    'UXm2'
    'UYm2'
    'UZm2'
    'UXm3'
    'UYm3'
    'UZm3'
    'UXm4'
    'UYm4'
    'UZm4'
    'UXm5'
    'UYm5'
    'UZm5'
    'ACTIVE_CHOICE'
    'ENABLED'
    'PEAK_RATIO'
    'MASK'
    'CORC'
    'FRAC_VALID'
    'FRAC_VALIDm1'
    'Time_for_prepare_and_peak'
    'Time_for_correlation'
    'Height'
    'Stereo_reconstruction_error'
    'Surface_height_reconstruction_error'
    'Height_of_deformed_image'
    'Height_of_deformed_image_mask'};

try
    headershort=mattConvention{strcmp(headerDavis,davisConvention)};
catch
    warning on
    warning([headerDavis,' needs to be added to ',mfilename,' in ',pwd,'.'])
    headershort=['UNEXPECTED_FIELD__',headerDavis];
end


end

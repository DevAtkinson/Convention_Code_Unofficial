function [crack,JVALS,KVALS,TVALS]=getFEMCRACKall6(filename,crack_old,flip_if_true)
% have the option to add these values to existing crack.
% filename='C:\Users\18096433\Desktop\BIG DATA\Abaqus_models\S07_inclined_notch3\S07_linear_standard';
%
% JVALS, KVALS and TVALS contain all J K and T values:
% rows are points on the crack front, e.g. view convergence plot(crackfen.JVALS(13,:))
% columns are contours, e.g. view convergence plot(crackfen.JVALS(13,:))
if ~exist('flip_if_true','var')
    flip_if_true=false;
end

filename=[filename,'.dat'];
fid=fopen(filename,'rt');
if fid == -1, error('Cannot open file'), end

j_heading='J - I N T E G R A L   E S T I M A T E S';
k_heading='K   F A C T O R       E S T I M A T E S';
t_heading='T - S T R E S S   E S T I M A T E S';

Data = textscan(fid, '%s','delimiter', '\n', 'whitespace', '');
cstr = Data{1};
fclose(fid);

findjline=true;
findkline=true;
findtline=true;
jline=0;
kline=0;
tline=0;

store_blocks=false; % number of blocks to store
kill_pattern='LABELS REFERENCED';
nums2d=[];
AA=cell(3,1);
NEXT=0;
for ii=1:length(cstr)
    linei=cstr{ii};
    
    % Find J
    if findjline
        if isstringthere(linei,j_heading)
            disp(['''',j_heading, ''' search starting from line: ',num2str(ii)])
            jline=ii;
            findjline=false;
            store_blocks=true;
        end
    end
    
    % Find K factors
    if findkline
        if isstringthere(linei,k_heading)
            disp(['''',k_heading, ''' search starting from line: ',num2str(ii)])
            kline=ii;
            findkline=false;
            store_blocks=true;
        end
    end
    
    % Find T-stress
    if findtline
        if isstringthere(linei,t_heading)
            disp(['''',t_heading, ''' search starting from line: ',num2str(ii)])
            tline=ii;
            findtline=false;
            store_blocks=true;
        end
    end
    
    if store_blocks
        kill_if_true = isstringthere(linei,kill_pattern);
                    
        if ~kill_if_true
            [numsout,num_nums,numbefore] = maxnumsfromline(linei);
            if num_nums>=1
                if num_nums<=5
                    if num_nums<5
                        [rr,cc]=size(numsout);
                        numsout=[numsout,nan(rr,5-cc)]; %pad nans up to length 5
                    end
                    nums2d=[nums2d;numsout,numbefore];
                end
            end
            
            if num_nums>5
                disp('when I wrote this code - I assume that Abaqus tables are always max columns ==5')
                dispiftrue(true,', this value has been exceeded. :p')
            end
            %                 numsout
            %                 num_nums
            %                 numbefore

        else
            NEXT=NEXT+1;
            disp('A section of the .dat file (text searching) is complete.')
            AA{NEXT}=nums2d;
            nums2d=[];
            store_blocks=false;
        end
        
        
    end
end
disp(' ')

J=AA{1};
K=AA{2};
T=AA{3};

% J values:
JVALS = reblock_fif(J,1);
J     = JVALS(:,end);

id=1:length(J);
if flip_if_true
    id=fliplr(id);
end

JVALS = JVALS(id,:);
J = J(id);

%% T - Stress values
TVALS = reblock_fif(T,1);
TVALS = TVALS(id,:);
T     = TVALS(:,end);


%% K SIF values
KVALS=reblock_fif(K,5);
KVALS = KVALS(id,:,:);

% Take final K values:
KI        =squeeze(KVALS(:,end,1));
KII       =squeeze(KVALS(:,end,2));
KIII      =squeeze(KVALS(:,end,3));
MTSdir    =squeeze(KVALS(:,end,4));
JfromK    =squeeze(KVALS(:,end,5));

% add to crack:
if exist('crack_old','var')
    crack=crack_old;
end

crack.J    =J(:);
crack.T    =T(:);
crack.KI        =KI(:);
crack.KII       =KII(:);
crack.KIII      =KIII(:);
crack.MTSdir    =MTSdir(:);
crack.JfromK    =JfromK(:);
crack.JVALS=JVALS;
crack.KVALS=KVALS;
crack.TVALS=TVALS;

end

function OUTPUT_VALS=reblock_fif(fracture_parameter_block,block_lines)
% Just fetches the values from block data
nancol=fracture_parameter_block(:,end);
nancol(nancol~=0)=nan;
vals=fracture_parameter_block(:,1:end-1);
% block_lines=1;

allrows=[];
rowii=[];
id=find(isnan(nancol));
start_true=false; %^&* changed this

for ii=id(1):block_lines:length(nancol)
    
    if isnan(nancol(ii))&&start_true
        allrows=cat(3,allrows,rowii);
        rowii=[];
    end
    
    ri=vals(ii:ii+block_lines-1,:);
    [~,bb]=find(~isnan(ri));
    ri=ri(:,1:max(bb));
    rowii=[rowii,ri] ;
    
    start_true=true;
end

% catch the last row: %^&* recent bug fix
allrows=cat(3,allrows,rowii);


OUTPUT_VALS=permute(allrows,[3,2,1]);
end



function [numsout,num_nums,numbefore] = maxnumsfromline(linei)
%MAXNUMSFROMLINE Function grabs the maximum number of numbers in a string.

%   numsout is the numbers given in an array.
%   num_nums is the number of numbers found in that line.

startat=0;
bb=nan(size(linei));
while startat<=length(linei)
    startat=startat+1;
    
    numsout=sscanf(linei(startat:end),'%g', 100);
    
    if isempty(numsout)
        laa=0;
    else
        laa=length(numsout);
    end
    bb(startat)=laa;
end

[num_nums,stringat]=max(bb);
numsout=sscanf(linei(stringat:end),'%g', 100);
numsout=numsout';

% get if there was a number before teh block...
numbefore=sscanf(linei(1:stringat-1),'%g', 100);
if isempty(numbefore)
    numbefore=0;
end
numbefore=numbefore(end);

end

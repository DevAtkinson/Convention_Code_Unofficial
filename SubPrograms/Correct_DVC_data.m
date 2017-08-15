% Function to create an alternative way for storing the DVC data so that it can be displayed correctly
function [out]=Correct_DVC_data(it)
    [y_size,x_size,z_size]=size(it);
    out=zeros(z_size,y_size,x_size);
    for i=1:z_size
        out(i,:,:)=it(:,:,i);
    end
end
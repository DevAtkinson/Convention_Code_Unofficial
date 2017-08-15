function [imghandle]=test_disp(ax,x,y,field)
	 x_tick=sort([field.POSX(1,1),field.POSX(1,end)]);
        y_tick=sort([field.POSY(1,1),field.POSY(end,1)]);
	axes(ax)
    imghandle =imagesc(x_tick,y_tick,field.UX(:,:,50));
    imghandle =impoint(ax,[x,y]);
end
function [true_false] = isstringthere(string,pattern)
%ISSTRINGTHERE Returns true if pattern is in the ignoring case.
% if patthern is empty ('') then string there is true.
if ~isempty(pattern)
    
    aa=regexp(lower(string),lower(pattern));
    if isempty(aa);
        true_false=false; %nothing found
    else
        true_false=logical(aa(1)); %found it!
    end
    
else
    true_false=true;
end

end


function trimmedVec = trimzeros(zerosVec,dim)
%TRIMZEROS Summary of this function goes here
%   Detailed explanation goes here
arguments
    zerosVec double
    dim string = "1"
end
if dim == "1"
    X = any(zerosVec==0,1);
else
    X = any(zerosVec==0,dim);
end
zerosVec(X) = [];
trimmedVec = zerosVec;
end


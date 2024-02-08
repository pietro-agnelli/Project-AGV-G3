function trimmedVec = trimzeros(zerosVec)
%TRIMZEROS Summary of this function goes here
%   Detailed explanation goes here
X = any(zerosVec==0,1);
zerosVec(X) = [];
trimmedVec = zerosVec;
end


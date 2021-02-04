function [Alphavector]=fetchalpha(Model,N)
Alphaindex=Model.sv_indices; %Indices where alpha is non-zero
AlphaValue=Model.sv_coef; %values of Alpha
Alphavector=zeros(N,1); %Generate a vectror of zeros
for qq=1:size(Alphaindex,1)
Alphavector(Alphaindex(qq))=AlphaValue(qq);
end
end

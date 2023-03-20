function CI = CITest_ChiTwoVar( MI, R, M, a )
% Input:
% MI is the mutual information of I(X1,X2) or I(X1,X2|others );
% M is the number of sample used
% a is  0.05

%Output:
% if CI = 1,X1 and X2 independent, otherwise,dependent
% Null hypothesis is X1 and X2 are independent

   CI = 0; 
   Threshold = chi2inv( 1-a,R );
   if  Threshold < 2*M*MI      %|| ThresholdLarge < 2*N*MI
       CI = 1;    
   end
end
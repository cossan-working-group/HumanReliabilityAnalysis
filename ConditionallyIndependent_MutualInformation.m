function [MI,R,M ] = ConditionallyIndependent_MutualInformation( LGObj,Var1,Var2,ConditionalVar )
% VarData1,VarData2,and ConditionalData must have the same number of rows
% I(VarData1,VarData2|ConditionalData )

if nargin == 3 || isempty( ConditionalVar ) == 1 
    [MI,R,M ] = MarginallyIndependent_MutualInformation( LGObj,Var1,Var2);
    return
end
MI = 0;
LG = struct( LGObj );

    N  = LG.CaseLength;
    OriginalData = LG.VarSample;
    UsedSample = DiscardNoneExist( LG.VarSample,[ Var1,Var2,ConditionalVar ] );
    M = N - sum( UsedSample );

     Range1 = LG.VarRange( Var1,: );
     Dim1 = LG.VarRangeLength( Var1 );
     Range1 = Range1( 1:Dim1 );

     Range2 = LG.VarRange( Var2,: );
     Dim2 = LG.VarRangeLength( Var2 );
     Range2 = Range2( 1:Dim2 );

R =( Dim1 -1 ) * ( Dim2 - 1 );
R = R * prod( LG.VarRange( ConditionalVar ));

% The location of the first unprocessed sample, it accelerates the
% searching. 
  d = 1 ; 
  while d <= N
      Frequency = zeros( Dim1,Dim2 ); 
      while d <= N && UsedSample( d ) == 1  
          d = d + 1;
      end
      if d > N,break;end
      ParentValue = OriginalData( d, ConditionalVar );
      
      for t1 = 1:Dim1
          if Range1( t1 ) == OriginalData( d,Var1 )
              break;
          end
      end
      
      for t2 = 1:Dim2
          if Range2( t2 ) == OriginalData(d, Var2 )
              break;
          end
      end      
      Frequency( t1,t2 ) =  1;
    % VarValue
     UsedSample( d )=1;
     d = d + 1;
     if d > N,break;end
    % test whether the class value in Sample(t) is the same as VarValue or not. 
     for t = d:N
         if UsedSample( t )==0
             if ParentValue == OriginalData( t, ConditionalVar )
                  t1 = find( Range1 == OriginalData( t,Var1 ));
                  t2 = find( Range2 == OriginalData( t,Var2 ));                
                  Frequency(t1,t2) = Frequency(t1,t2) + 1;
                  UsedSample(t) = 1;
                  %Frequency
             end
         end 
     end
     
      %UsedSample
      %Frequency
      %Fu = zeros(Dim1(1),1); Fv = zeros(1,Dim2(1));      
      Fu = sum( Frequency,2 );
      Fv = sum( Frequency,1 );
      Sum= sum(Fu);
     % 1/20 * log2(1*2/1*1);
      
       for u= 1 : Dim1
            for v=1 : Dim2 
                if Frequency(u,v) ~= 0  % it also makes sure  Fu(u)~=0 and Fv(v) ~=0
                    MI = MI + ( Frequency(u,v)/M ) * log2( Frequency(u,v)*Sum / (  Fu(u)*Fv(v) ) );   
                end
            end
       end
      % WI
  end

end


function [MI,R,N ] = MarginallyIndependent_MutualInformation( LGObj, Var1,Var2 )
% calculate the mutual information between two variables
% Input:Vector VarData1 and VarData2 is the data of X1 and X2. 
% Output: MI is the mutual information.
%         r1 and r2 is the number of different values in VarData1 and
%         VarData2
%         N is the validate samples used

     LG = struct( LGObj );
     
     CaseLength = LG.CaseLength;
     Range1 = LG.VarRange( Var1,: );
     Dim1 = LG.VarRangeLength( Var1 );
     VarData1 = LG.VarSample( :,Var1 );

     Range2 = LG.VarRange( Var2,: );
     Dim2 = LG.VarRangeLength( Var2 );
     VarData2 = LG.VarSample( :,Var2 );
   
  R = ( Dim1 - 1 ) *( Dim2 - 1 );
  Frequency = zeros( Dim1,Dim2 );  
  N = 0;
  for q = 1 : CaseLength     % size(VarData1,1) = size(VarData2,1)  
      t1 = find( Range1( 1:Dim1 ) ==  VarData1( q ) );    
      t2 = find( Range2( 1:Dim2 ) ==  VarData2( q ) );
      if isempty( t1 ) == 0 && isempty( t2 ) == 0  % There is possible that t1 or t2 is empty because of invalid value -1 exits.
          Frequency( t1, t2 ) = Frequency( t1, t2 ) + 1;
         N = N + 1;
      end
  end

%  Frequency
  Frequency = Frequency /N;
  Fu        = sum( Frequency,2 );  % Set dim to 1 to compute the sum of each column, 2 to sum rows, etc.
  Fv        = sum( Frequency,1 );
      
  %Fu
  %Fv
  MI=0;
  for u=1 : Dim1
      for v= 1 : Dim2
          if Frequency( u,v ) ~= 0 
              MI = MI + Frequency(u,v)*log2( Frequency(u,v)/(  Fu(u)*Fv(v) ));   
          end
      end
  end
  
end

function  [Discard,TotalNumber ] = DiscardNoneExist( OriginalData,TestVector )
% This function return a matric indicating the useful rows in OriginalData.  
% Input:  TestVector is the variables in OriginalData
%         TestVector is the set of variables.
% Output: Discard is a tag matric showing which rows in OriginalData are used

% U is the given value when the data is invalid. 
N = size(OriginalData,1); % U;  
Discard = zeros(1,N);
TotalNumber = 0;
  for p=1:N
      d = 1;
      for q = 1:size(TestVector,2)
          if OriginalData(p,TestVector(q)) == -1   % Here we assume U =-1
             d = 0;
             break;
          end
      end
      if d==0 
          Discard(p) = 1;
          TotalNumber = TotalNumber + 1;
      end
  end
end

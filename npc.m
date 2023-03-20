function DG = npc( LGObj,a )
%The PC algorithm:
%Input: Training database, a is thredhold of CI test
%Output: a directed graph.
%Step 1. Create a complete graph G on the variables in U:
%Step 2. n := 0.
%   2.1. Repeat Until all ordered pairs of adjacent variables (x; y) such that |Ad(x)\{y}| >n and every subset S in Ad(x)\{y} have been 
%        tested for independence.Select an ordered pair of variables x; y adjacent in G such that |Ad(x)\{y}| < n.Select a subset S of 
%        Ad(x)\{y} with cardinality n.If I(x|S|y) where S is on the path from x to you, then erase x--y from G.. Store S in the sets Separating (x; y) and Separating (y; x).
%   2.2. n := n + 1.
%Step 3. For each triplet of nodes x; y; z where x and y are adjacent, and y and
%z are adjacent but x and z are not adjacent, orient x ->y<- z if and only if y does not belong to Separating (x; z).

LG = struct(LGObj);
Dim = LG.VarNumber;
S = cell(Dim);

% Step 1: Complete undirected graph H
DG = ones( Dim );  % A directed graph
for q = 1:Dim
    DG( q,q ) = 0;
end

% Step2, test every independence relationship
% at first, test the mutual information I(xi,xj)
for p = 1 : ( Dim - 1 )
     for q = ( p + 1): Dim
          [MI,R,M ] = ConditionallyIndependent_MutualInformation( LGObj,p,q );
           CI = CITest_ChiTwoVar( MI,R,M,a);
             if CI == 1                              
                DG( p,q ) = 0;  DG( q,p ) = 0;
             end
     end
 end
             
%Second, take out the test I( xi,xj|Nodes in path from xi to xj )

 Run = 1; N = 1;
    while Run == 1
          Run = 0; flag = 0;
          for p = 1:( Dim -1 )
             for q = ( p+1 ):Dim
                if DG( p,q ) == 1                                   
                   TempVector = DG( :,q )';
                   TempVector( p ) = 0;
                   U = find( TempVector > 0 );
                   % Here is the important improvement for NPC....
                   for t = length( U ):( -1 ):1
                       if graphshortestpath( sparse( DG ) , U( t ), p ) == Inf
                           U( t ) = [];
                       end
                   end
                           
                   if length( U ) >= N
                      flag = 1; 
                      Combination = combntns( U,N );
                      for n = 1:size( Combination,1 ) 
                            [MI,R,M ] = ConditionallyIndependent_MutualInformation( LGObj,p,q,Combination( n,: ) );
                                   CI = CITest_ChiTwoVar( MI,R,M,a  );
                            if CI == 1                              
                               DG( p,q ) = 0;  DG( q,p ) = 0;
                               S{p,q} = Combination(n,:);
                               break;      % If there exist one subset s ,then erase the arc between q and p
                            end
                      end                        
                   end                    
                end                 
             end              
          end
           N = N + 1;
          if flag == 1
              Run = 1;
          end
    end 
 
% Third, take out the test I( x,y|z ) if x--y,y--z,z--x, after this, no more test takes out.    



%DG1 = DG
%Step 3 give head to head direction x-->y<--z
% For each uncoupled meeting X�CZ��Y, if Z belongs to SXY, Orient X�CZ-Y as X ->Z<-- Y 
for p = 1: Dim      
    for q = 1 : Dim
        if DG( p,q ) == 1
            AdjacentNode = find( DG( q,: ) == 1 );
            for t =1 : size( AdjacentNode,2 )
                if AdjacentNode( t ) ~= p && DG( p,q ) == 1 && DG( q,p ) == 1 ...
                        && DG(q,AdjacentNode(t)) == 1 && DG( AdjacentNode(t),q ) == 1
                    if isempty( find( S{p,AdjacentNode(t)} == q ) ) == 1 %#ok<EFIND>
                        DG( q,p ) = 0;
                        DG( q,AdjacentNode(t) ) = 0;
                    end
                end
            end
        end
    end
end

%DG2 = DG
%h3 = view(biograph( DG2 ))
Run = 1;
while Run == 1
      Run = 0;
      for p = 1 :  Dim
          for q = 1  : Dim
              % Rule 1 and Rule 2
              if DG( p,q ) == 1 && DG( q,p ) == 0  % a --> b
                 Adjacent = DG( q,: );
                 for t = 1 :Dim
                     % Rule 1 : if a-->b --c then, b --> c
                     if Adjacent( t ) == 1 && DG( t,q ) == 1 ...% b--c
                         && DG( p,t )==0 && DG( t,p )==0  % I(a,c) 
                             DG( t,q ) = 0;
                             Run = 1;
                     % Rule 2: if a-->b,b-->c and a--c,then a-->c    
                     elseif Adjacent( t ) == 1 && DG(t,q)==0 ... % b-->c
                          && DG( p,t ) == 1 && DG( t,p ) == 1 % a--c
                             DG(t,p) =0;
                             Run = 1;
                     end
                 end
              end
              if Run == 1
                %  DG2 = DG
              end
               % Rule 3 and Rule 4 
             if DG( p,q ) == 1 && DG( q,p ) == 1  
                 DescendantX = DG( p,: );  
                 DescendantZ = DG( q,: ) ;
 
                 % Rule 3: if a--b,b--c,b--d,a-->d,c-->d, then b-->d
                 % p,q is for a--b
                 for m = 1 : Dim
                      if DescendantX( m ) == 1 && DescendantZ( m ) == 1 ...
                              && DG( m,q ) ==1 && DG( m,p )==0  % find d
                         DescendantY = DG(:,m)';
                         for t = 1 : Dim
                             if  t ~= q && DescendantY( t ) == 1 && DG( t,q )==1 ... 
                                 && DG( q, t )==1 && DG( t,p ) == 0 && DG( p,t )==0  % find c 
                                 Run = 1;
                                 DG( q,t ) = 0;
                             end
                         end
                      end
                 end
              if Run == 1
                %  DG3 = DG
              end
                 % Rule 4: if a��b ,b��c, a��c,c��d,d->a, then direct a->b<-c
                 % p,q is for a--c
                 for m = 1 : Dim
                     if DescendantX( m ) == 1 && DescendantZ( m ) == 1 ...
                             && DG( m,q ) == 1 && DG( m,p ) == 1  % find b
                          for n = 1 : Dim
                              if n ~= m && n~= p && DescendantZ( n ) == 1 ...
                                      && DG( n,q ) == 1 && DG( n,m )==0 && DG( m,n ) == 0 % find d
                                         DescendantD = DG( n,: );
                                      if DescendantD( p ) == 1 && DG(p,n) == 0
                                          Run = 1;
                                          DG( m,p)=0;
                                          DG( m,q)=0;
                                      end
                              end
                          end
                     end
                 end
                 
              if Run == 1
               %   DG4 = DG
              end
                 
             end
          end
      end                   
end

if  graphisdag( sparse( DG )) == 0
    for p = 1:Dim
        for q = 1:Dim
           if DG( p,q ) == 1 &&DG( q,p ) == 1
              DG( q,p ) = 0;
          elseif DG( p,q ) == 1 && TestPathInGraph(DG,q,p) == 1
              DG( p,q ) = 0;
          end
       end
    end
end
      
%   h3 = view(biograph( DG ))
      
end
        

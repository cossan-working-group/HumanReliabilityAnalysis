clear all

listM={'K2','NPC','Expert','Aggregated'};
M = listdlg('PromptString','Choose one method','Liststring',listM,'SelectionMode','single'); %M=chosen method

if M==2
    listSL={'0.01','0.1','0.5','1','2.5','5','10'} ;
    SL = listdlg('PromptString','Choose Significance Level','ListString',listSL,'SelectionMode','single');
    SL=cell2mat(listSL(SL)); %SigLevel for NPC algorithm
else if M==1
    listNP={'1','2','3','4','5','6','7','8','9','10'};
    NP = listdlg("PromptString",'Choose Maximum Number of Parents per Node','SelectionMode','single','ListString',listNP);
    NP=cell2mat(listNP(NP)); %max number of parents for K2 algorithm
end 
end

if M==4
    listSL={'0.01','0.1','0.5','1','2.5','5','10'} ;
    SL = listdlg('PromptString','Choose Significance Level','ListString',listSL,'SelectionMode','single');
    SL=cell2mat(listSL(SL)); %SigLevel for NPC algorithm
    listNP={'1','2','3','4','5','6','7','8','9','10'};
    NP = listdlg("PromptString",'Choose Maximum Number of Parents per Node','SelectionMode','single','ListString',listNP);
    NP=cell2mat(listNP(NP)); %max number of parents for K2 algorithm 
end

listG={'Grouped Factors','Ungrouped Factors'};
G = listdlg('PromptString','Choose grouped or ungrouped performance shaping factors','Liststring',listG,'SelectionMode','single'); %M=grouped/ungrouped

if G==1
listF={'Action','Observation','Interpretation','Planning','Temporary Person Related Functions','Permanent Person Related Functions','Equipment','Procedures','Temporary Interface','Permanent Interface','Communication','Organisation','Training','Ambient Conditions','Working Conditions'};
F = listdlg("PromptString",'Choose the Grouped Factors of interest','ListString',listF);
else if G==2
listF={'Wrong Time','Wrong Type','Wrong Object','Wrong Place','Observation Missed','False Observation','Wrong Identification','Faulty diagnosis','Wrong reasoning','Decision error','Delayed interpretation','Incorrect prediction','Inadequate plan','Priority error','Memory failure','Fear','Distraction','Fatigue','Performance Variability','Inattention','Physiological stress','Psychological stress','Functional impairment','Cognitive style','Cognitive bias','Equipment failure','Software fault','Inadequate procedure','Access limitations','Ambiguous information','Incomplete information','Access problems','Mislabelling','Communication failure','Missing information','Maintenance failure','Inadequate quality control','Management problem','Design failure','Inadequate task allocation','Social pressure','Insufficient skills','Insufficient knowledge','Temperature','Sound','Humidity','Illumination','Other','Adverse ambient conditions','Excessive demand','Inadequate work place layout','Inadequate team support','Irregular working hours'};
F = listdlg("PromptString",'Choose the Factors of interest','ListString',listF);
    end
end

listFI={};

if G==1
for i=1:size(F,2)
listFI(end+1)=listF(F(i));
end
listN={'Node 1','Node 2','Node 3','Node 4','Node 5','Node 6','Node 7','Node 8','Node 9','Node 10','Node 11','Node 12','Node 13','Node 14','Node 15'}
    Key=[listFI',listN(1:length(listFI))']
else if G==2
for i=1:size(F,2)
listFI(end+1)=listF(F(i));
end 
listN={'Node 1','Node 2','Node 3','Node 4','Node 5','Node 6','Node 7','Node 8','Node 9','Node 10','Node 11','Node 12','Node 13','Node 14','Node 15','Node 16','Node 17','Node 18','Node 19','Node 20','Node 21','Node 22','Node 23','Node 24','Node 25','Node 26','Node 27','Node 28','Node 29','Node 30','Node 31','Node 32','Node 33','Node 34','Node 35','Node 36','Node 37','Node 38','Node 39','Node 40','Node 41','Node 42','Node 43','Node 44','Node 45','Node 46','Node 47','Node 48','Node 49','Node 50','Node 51','Node 52','Node 53'};
Key=[listFI',listN(1:length(listFI))']
    end
end

if G==1
Sample = readmatrix('MATA_D_Matrix_Grouped.xlsx');
Sample = Sample(:,F);
else if G==2
Sample = readmatrix('MATA_D_MatFormFull.xlsx');
Sample = Sample(:,F);
    end
end

if M==1
    LGObj_K2 = ConstructLGObj_K2( Sample);
    Order = randperm(width(Sample));
    [ DAG,K2Score ] = k2( LGObj_K2,Order,NP);
    DAG=DAG';
    G = digraph(DAG,listFI); 
        plot(G)
else if M==2
        LGObj = ConstructLGObj_NPC( Sample );
        DAG = npc( LGObj,SL)';
        G = digraph(DAG,listFI); 
        DAG=DAG';
        plot(G)
else if M==3
        if G==1
        DAG = readmatrix('Grouped_ExpertOp.xlsx');
        DAG = DAG(F,F)';
        G=digraph(DAG,listFI);
        plot(G)
        else if G==2
        DAG = readmatrix('Expert Links Format.xlsx');
        DAG = DAG(F,F)';
        G=digraph(DAG,listFI);
        plot(G)
            end
        end
  else if M==4
             LGObj_K2 = ConstructLGObj_K2( Sample);
             Order = randperm(width(Sample));
             [DAG1,K2Score ] = k2( LGObj_K2,Order,NP);
             DAG1=DAG1';
              LGObj = ConstructLGObj_NPC( Sample );
              DAG2 = npc( LGObj,SL)';
              DAG2=DAG2';
        if G==1
        DAG3 = readmatrix('Grouped_ExpertOp.xlsx');
        DAG3 = DAG3(F,F)';
        else if G==2
        DAG3 = readmatrix('Expert Links Format.xlsx');
        DAG3 = DAG3(F,F)';
            end
        end
        DAGA=DAG1+DAG2+DAG3;
        for i=1:size(DAGA,2)
            for j=1:size(DAGA,1)
                if DAGA(i,j)<2
                    DAGA(i,j)= 0 
                else if DAG(i,j)>=2
                        DAGA(i,j)=1
                end
            end
        end
        G=digraph(DAGA,listFI);
        plot(G)
        end
    end
    end
    end
end




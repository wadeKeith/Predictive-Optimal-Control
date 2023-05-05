function [df1,df2] = func_build_cs_real_data(df)
    df = [df(:,1),zeros(length(df),5)];
    df1 =df;
    df2 = df;
    %% constant speed
    for i=1:length(df)-5
        
        for j = 1:5
            df1(i,j+1) = df(i,1);
        end
    end
    
    %% real time
    for i=1:length(df)-5
        
        for j = 1:5
            df2(i,j+1) = df(i+j,1);
        end
    end
end


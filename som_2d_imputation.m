% 2-D imputation method using Self-Organizing Map (SOM).
% Number of missing values is set to 10,20 or 30% of total values.
% Dataset is scanned and clustered when a missing value is found.
% Cluster pattern is searched and missing values are imputed accordingly.
% Mean Absolute Error, Mean Absolute Percentage Error, Mean Relative Error,
% Mean Relative Percentage Error are displayed in the end, as well as a
% timeseries plot comparing initial and imputed datasets.

% x = rand(7,7); % Generate random matrix
input = readtable('neaelvetia_2011_365x24_pu.xlsx');
% input = readtable('volos_wind_at_10m_speed_2018_2020.xlsx');
x = table2array(input);
height = size(x,1);
length = size(x,2);
%x

initial = x;

% nans_num = round(numel(x) * 0.1);
% nans_num = round(numel(x) * 0.2);
nans_num = round(numel(x) * 0.3);
idx = randperm(numel(x),nans_num); % Random indexes of NaN values (n,k) (k integers from 1 to n)
x(idx(1:nans_num)) = NaN; % Random NaN values
x

transpose_matrix = x';
row_with_max_nans = 0;
max_nan_count_of_row = 0;
for col=1:height
    row_nan_count = 0;
    for row=1:length
        if(isnan(transpose_matrix(row,col))==1)
            row_nan_count = row_nan_count + 1;
        end
    end
    if row_nan_count > max_nan_count_of_row
        max_nan_count_of_row = row_nan_count;
        row_with_max_nans = col;
    end
end
row_with_max_nans
max_nan_count_of_row

permanent = x;
% x = permanent;

final = x;
% x serves as temporary array 

k=isnan(x(:));
nan_list=find(k); % linear indices
known_list=find(~k);
nan_count=size(nan_list,1)
[nr,nc]=ind2sub([height,length],nan_list);% convert NaN linear indices to (r,c) form
nan_list=[nan_list,nr,nc]; % linear index, row, col 

nan_values = isnan(x);
non_nan_values = ~nan_values;
index_of_first_non_nan = find(non_nan_values,1,'first'); 
% First non-NaN value

tic
% Impute x using locf method, because selforgmap can't work with NaN values
for col=1:length;
    for row=1:height;
        if(nan_values(row,col) == 1)
            if(row == 1)
                [temp_row, temp_col] = first_non_nan_col(row, col, x, height);
                x(row,col) = x(temp_row,temp_col);
            else
                x(row,col) = x(row-1,col);
            end
        end
    end
end

net = selforgmap([3 1]);
net = train(net,x');
%view(net);
y = net(x');
clusters = vec2ind(y)

for j = 1:length
    for i = 1:height
        if(nan_values(i,j) == 1)
            sum = 0;
            times_found = 0;
            cluster_searched = clusters(1,i)
            
            for k =1:height
                if(clusters(1,k) == cluster_searched)
                    if(isnan(final(k,j)) == 0)
                        times_found = times_found + 1;
                        sum = sum + final(k,j);
                    end
                end
            end
            
            if(times_found == 0)
                [temp_row, temp_col] = last_non_nan_col(row, col, final, height);
                final(i,j) = final(temp_row,temp_col);
                continue;
            end
            
            final(i,j) = sum / times_found;
        end
    end
end

final


k=isnan(final(:));
nan_list=find(k); % linear indices
known_list=find(~k);
nan_count=size(nan_list,1)

deviation1 = initial - final;
deviation1 = abs(deviation1);
mae = mean2(deviation1)

deviation2 = initial - final;
deviation2 = deviation2 ./ initial;
deviation2 = abs(deviation2);
mape = mean2(deviation2) * 100

deviation3 = initial - final;
mre = mean2(deviation3)

deviation4 = initial - final;
deviation4 = deviation4 ./ initial;
mrpe = mean2(deviation4) * 100

toc

% a = final(:);
% ts1 = timeseries(a);
% figure
% plot(ts1, '-k', 'MarkerSize', 6)
% grid on
% hold on
% b = initial(:);
% ts2 = timeseries(b);
% plot(ts2, '--r','MarkerSize', 6 )
% legend('Completed', 'Actual')

%Daily timeseries comparison for the day with the most missing values

a = final(row_with_max_nans,:);
ts1 = timeseries(a);
figure
plot(ts1, '-k', 'MarkerSize', 6)
grid on
hold on
b = initial(row_with_max_nans,:);
ts2 = timeseries(b);
plot(ts2, '--r','MarkerSize', 6 )
legend('Completed', 'Actual')
                    
                    
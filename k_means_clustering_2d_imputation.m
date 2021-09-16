% 2-D imputation method using k-means algorithm.
% Number of missing values is set to 10,20 or 30% of total values.
% Dataset is scanned and clustered when a missing value is found.
% Cluster pattern is searched and missing values are imputed accordingly.
% Mean Absolute Error, Mean Absolute Percentage Error, Mean Relative Error,
% Mean Relative Percentage Error are displayed in the end, as well as a
% timeseries plot comparing initial and imputed datasets.

% x = rand(9,9); % Generate random matrix
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
x;

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

k=isnan(x(:));
nan_list=find(k); % linear indices
known_list=find(~k);
nan_count=size(nan_list,1)
[nr,nc]=ind2sub([height,length],nan_list);% convert NaN linear indices to (r,c) form
nan_list=[nan_list,nr,nc] % linear index, row, col 

nan_values = isnan(x);
non_nan_values = ~nan_values;
index_of_first_non_nan = find(non_nan_values,1,'first'); 
% First non-NaN value

tic
for col=1:length
    for temp_row = 1:height
        if(nan_values(temp_row, col) == 0)
            first_non_nan_of_col = x(temp_row,col);
            break;
        end
    end
    
    for row =1:height
        if (nan_values(row, col) == 1)
            initial_window = 3;
            if((row - initial_window) <= 1)
                x(row,col) = first_non_nan_of_col;
                continue;
            end
            x(1:row-1,col);
            
            %idc = kmeans(x(1:row-1,col),2); % for 2 clusters
            idc = kmeans(x(1:row-1,col),3); % for 3 clusters
            
            %temp_array = [idc(row-2,1) idc(row-1,1)];
            temp_array = [idc(row-3,1) idc(row-2,1) idc(row-1,1)]; % window = 3

            search_area = idc(1:row-initial_window-1,1);
            k = strfind(search_area',temp_array);
            k = k + initial_window;
            times_found = numel(k);
            if(times_found == 0 || times_found == 1)
                new_window = 2;
                temp_array = [idc(row-2,1) idc(row-1,1)];
                search_area = idc(1:row-new_window-1,1);
                k = strfind(search_area',temp_array);
                k = k + new_window;
                times_found = numel(k);
                if(times_found == 0 || times_found == 1)
                    new_window = 1;
                    temp_array = [idc(row-1,1)];
                    search_area = idc(1:row-new_window-1,1);
                    k = strfind(search_area',temp_array);
                    k = k + new_window;
                    times_found = numel(k);
                    if(times_found == 0 || times_found == 1)
                        if(row == 1)
                            [temp_row, temp_col] = first_non_nan_col(row, col, x, height);
                            x(row, col) = x(temp_row, temp_col);
                            x;
                            continue;
                        end
                        [temp_row, temp_col] = last_non_nan_col(row, col, x, height);
                        x(row, col) = x(temp_row, temp_col);
                        x;
                        continue;
                    end
                end
            end
            sum = 0;
            for(i=1:times_found)
                if(isnan(x(k(i),col)) == 0)
                    sum = sum + x(k(i),col);
                end
            end
            x(row,col) = sum / times_found;
            x;
        end
    end
end

x;

k=isnan(x(:));
nan_list=find(k); % linear indices
known_list=find(~k);
nan_count=size(nan_list,1)

deviation1 = initial - x;
deviation1 = abs(deviation1);
mae = mean2(deviation1)

deviation2 = initial - x;
deviation2 = deviation2 ./ initial;
deviation2 = abs(deviation2);
mape = mean2(deviation2) * 100

deviation3 = initial - x;
mre = mean2(deviation3)

deviation4 = initial - x;
deviation4 = deviation4 ./ initial;
mrpe = mean2(deviation4) * 100

toc

% a = x(:);
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

a = x(row_with_max_nans,:);
ts1 = timeseries(a);
figure
plot(ts1, '-k', 'MarkerSize', 6)
grid on
hold on
b = initial(row_with_max_nans,:);
ts2 = timeseries(b);
plot(ts2, '--r','MarkerSize', 6 )
legend('Completed', 'Actual')

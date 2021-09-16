% 2-D imputation method using k-nearest neighbour algorithm.
% Number of missing values is set to 10,20 or 30% of total values.
% Mean Absolute Error, Mean Absolute Percentage Error, Mean Relative Error,
% Mean Relative Percentage Error are displayed in the end, as well as a
% timeseries plot comparing initial and imputed datasets.

% Working of transposed matrix, because knnimpute function imputes using
% columns, and i want rows imputation, so i double transpose.

% x = rand(9,9) % Generate random matrix
input = readtable('neaelvetia_2011_365x24_pu.xlsx');
x = table2array(input);
height = size(x,1);
length = size(x,2);

initial = x;

nans_num = round(numel(x) * 0.1);
% nans_num = round(numel(x) * 0.2);
% nans_num = round(numel(x) * 0.3);
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
% x = x';
x = knnimpute(x,3); % Imputes using weighted mean of k neighbours
% x = x'

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



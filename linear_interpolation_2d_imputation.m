% 2-D imputation method using linear interpolation.
% Number of missing values is set to 10,20 or 30% of total values...
% Mean Absolute Error, Mean Absolute Percentage Error, Mean Relative Error,
% Mean Relative Percentage Error are displayed in the end, as well as a
% timeseries plot comparing initial and imputed datasets.

% x = rand(9,9); % Generate random matrix
input = readtable('neaelvetia_2011_365x24_pu.xlsx');
% input = readtable('volos_wind_at_10m_speed_2018_2020.xlsx');
x = table2array(input);
height = size(x,1);
length = size(x,2);
x

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
window = 3;
for col=1:length;
    for row=1:height;
        if(nan_values(row,col) == 1)
            if(row - window <= 0)
                display('YO');
                [temp_row, temp_col] = first_non_nan_col(row, col, x, height);
                x(row, col) = x(temp_row, temp_col);
                x
                continue;
            end
            if(row + window > height)
                display('YOYO');
                [temp_row2, temp_col2] = last_non_nan_col(row, col, x, height);
                x(row, col) = x(temp_row2, temp_col2);
                x
                continue;
            end
            if(window == 1)
                display('YO2');
                if(isnan(x(row-1,col)) == 1)
                    [temp_row, temp_col] = last_non_nan_col(row, col, x, height);
                    x(row, col) = x(temp_row, temp_col);
                    x
                    continue;
                end
                if(isnan(x(row+1,col)) == 1)
                    [temp_row, temp_col] = last_non_nan_col(row, col, x, height);
                    x(row, col) = x(temp_row, temp_col);
                    x
                    continue;
                end
                
                temp = [x(row-1,col) NaN x(row+1,col)];
                temp1 = fillmissing(temp, 'linear');
                x(row,col) = temp1(2);
                x
                continue;
            end
            if(window==2)
                display('yo2');
                if (isnan(x(row-2,col)) == 1) || (isnan(x(row-1,col)) == 1)
                    [temp_row, temp_col] = last_non_nan_col(row, col, x, height);
                    x(row, col) = x(temp_row, temp_col);
                    continue;
                end
                if (isnan(x(row+2,col)) == 1) || (isnan(x(row+1,col)) == 1)
                    [temp_row, temp_col] = last_non_nan_col(row, col, x, height);
                    x(row, col) = x(temp_row, temp_col);
                    continue;
                end
                temp1 = [x(row-2,col) NaN x(row-1,col)];
                temp2 = [x(row+1,col) NaN x(row+2,col)];
                res1 = fillmissing(temp1, 'linear');
                res2 = fillmissing(temp2, 'linear');
                temp3 = [res1(2) NaN res2(2)];
                final = fillmissing(temp3, 'linear');
                x(row,col) = final(2)
                continue;
            end
            if(window==3)
                display('yo3');
                if (isnan(x(row-2,col)) == 1) || (isnan(x(row-1,col)) == 1)|| (isnan(x(row-3,col)) == 1)
                    [temp_row, temp_col] = last_non_nan_col(row, col, x, height);
                    x(row, col) = x(temp_row, temp_col);
                    continue;
                end
                if (isnan(x(row+2,col)) == 1) || (isnan(x(row+1,col)) == 1)|| (isnan(x(row+3,col)) == 1)
                    [temp_row, temp_col] = last_non_nan_col(row, col, x, height);
                    x(row, col) = x(temp_row, temp_col);
                    continue;
                end
                temp1 = [x(row-3,col) NaN x(row-2,col)];
                temp2 = [x(row-2,col) NaN x(row-1,col)];
                temp3 = [x(row+1,col) NaN x(row+2,col)];
                temp4 = [x(row+2,col) NaN x(row+3,col)];
                res1 = fillmissing(temp1, 'linear');
                res2 = fillmissing(temp2, 'linear');
                res3 = fillmissing(temp3, 'linear');
                res4 = fillmissing(temp4, 'linear');
                temp5 = [res1(2) NaN res2(2)];
                temp6 = [res3(2) NaN res4(2)];
                res5 = fillmissing(temp5, 'linear');
                res6 = fillmissing(temp6, 'linear');
                temp7 = [res5(2) NaN res6(2)];
                final = fillmissing(temp7, 'linear');
                x(row,col) = final(2);
                continue;
            end
        end
    end
end

x

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
            
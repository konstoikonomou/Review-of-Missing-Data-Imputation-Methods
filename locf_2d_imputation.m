% 2-D imputation method using Last Observation Carried Forward (LOCF) method.
% Number of missing values is set to 10,20 or 30% of total values.

% x = rand(5,5); % Generate random matrix
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

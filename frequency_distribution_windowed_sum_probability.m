% 2-D imputation method using frequency distribution and sum probability of a window of values.
% Number of missing values is set to 10,20 or 30% of total values.
% Dataset is scanned and frequency distribution is created when a missing value is found.
% Sum probability of with the centres of areas is used to impute the missing value.
% Mean Absolute Error, Mean Absolute Percentage Error, Mean Relative Error,
% Mean Relative Percentage Error are displayed in the end, as well as a
% timeseries plot comparing initial and imputed datasets.

% x = rand(9,9); % Generate random matrix
% input = readtable('neaelvetia_2011_365x24_pu.xlsx');
input = readtable('volos_wind_at_10m_speed_2018_2020.xlsx');
x = table2array(input);
height = size(x,1);
length = size(x,2);
%x

% initial = 70 * x;
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

% Multiply by base to get real values (initial array is in per unit form)
% real_values_x = 70 * x
real_values_x = x;

tic
for col=1:length
    for row =1:height
        window = 6;
        if (nan_values(row, col) == 1)
            if(row == 1)
                [temp_row, temp_col] = first_non_nan_col(row, col, real_values_x, height);
                real_values_x(row, col) = real_values_x(temp_row, temp_col);
                continue;
            end
            if(row == height)
                [temp_row, temp_col] = last_non_nan_col(row, col, real_values_x, height);
                real_values_x(row, col) = real_values_x(temp_row, temp_col);
                continue;
            end
            while((row - window <= 0)||(row + window > height))
                window = window - 1;
                window
            end
            left_region = real_values_x(row-window:row-1, col)
            right_region = real_values_x(row+1:row+window, col)
            target = [left_region',right_region']
            %same_hours_windowed = real_values_x(:,col)
            %same_hours_all_days = same_hours_all_days(~isnan(same_hours_all_days))
            target = target(~isnan(target))
            [N, edges] = histcounts(target, 10)
            
%             histogram(target,edges,'DisplayStyle','bar');
%             xlabel('Value')
%             ylabel('Region members')
%             figure;
            
            % N: number of members of each region
            % edges: region limits
            probability_array = N / numel(target)
            
            prob_array_length = size(probability_array,2);
            for i=1:prob_array_length
                mid(i) = (edges(i+1) - edges(i)) / 2;
            end
            
            sum_probability = 0;
            
            for i = 1:prob_array_length
                sum_probability = sum_probability + mid(i) * probability_array(i);
            end
            
            real_values_x(row,col) = sum_probability;
        end
    end
end

real_values_x

k=isnan(real_values_x(:));
nan_list=find(k); % linear indices
known_list=find(~k);
nan_count=size(nan_list,1)

deviation1 = initial - real_values_x;
deviation1 = abs(deviation1);
mae = mean2(deviation1)

deviation2 = initial - real_values_x;
deviation2 = deviation2 ./ initial;
deviation2 = abs(deviation2);
mape = mean2(deviation2) * 100

deviation3 = initial - real_values_x;
mre = mean2(deviation3)

deviation4 = initial - real_values_x;
deviation4 = deviation4 ./ initial;
mrpe = mean2(deviation4) * 100

toc
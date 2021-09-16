% Function used in situations in which the missing value is located in the
% last row of the array or in higher position than the desired window, so
% the last non-NaN value of the column is used to help with the imputation.

function [non_nan_row, non_nan_col] = last_non_nan_col(row, col, array , height)
    for j=row-1:-1:1
        if(isnan(array(j,col)) == 0)
            non_nan_row = j
            non_nan_col = col
            return;
        end
    end
end
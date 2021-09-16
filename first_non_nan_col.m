% Function used in situations in which the missing value is located in the
% first row of the array or in lower position than the desired window, so
% the first non-NaN value of the column is used to help with the imputation.

function [non_nan_row, non_nan_col] = first_non_nan_col(row, col, array , height)
    for k=row+1:height
        if(isnan(array(k,col)) == 0)
            non_nan_row = k;
            non_nan_col = col;
            return;
        end
    end
end
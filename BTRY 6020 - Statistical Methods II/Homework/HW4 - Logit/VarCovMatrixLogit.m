%VAR-COV MATRIX LOGIT
%% Definir directorio
    dir = '\\tsclient\Andres\Dropbox\CORNELL\Spring 2017\BTRY 6020 Statistical Methods II\Homework\HW4\';
%% Lectura matrices    
% X MATRIX        
x = xlsread(strcat(dir,'Interpreting_logit_results.xlsx'),'matrix','A3:B29');
xt = x';
% V VECTOR
v = xlsread(strcat(dir,'Interpreting_logit_results.xlsx'),'matrix','C3:C29');
% OBSERVED PROBABIBILITIES
op = xlsread(strcat(dir,'Interpreting_logit_results.xlsx'),'matrix','D3:D29');
% FITTED PROBABILITIES
fp = xlsread(strcat(dir,'Interpreting_logit_results.xlsx'),'matrix','E3:E29');
%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS ESTIMATION
%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VAR-COV MATRIX = inv(x'*diag(v)*x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
varcov = inv(xt*diag(v)*x)


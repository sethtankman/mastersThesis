input = [HP_LP_diag,LP_LP_diag,UP_diag]';

HP_LP_diag = TL8(pos_trans:pos_diag);  
LP_LP_diag = TL9(pos_trans:pos_diag);
UP_diag = TL14(pos_trans:pos_diag);

TL14=tab.TL14s1;
TL9=tab.TL9s1;
TL8=tab.TL8s1;

tab = readtable(name_datafile9);
name_datafile9 = 'histories_short_print_400.csv';
[val_trans,pos_trans] = min(abs(time-t_acc));
[val_diag,pos_diag] = min(abs(time-t_recmd));

[readtable('histories_short_print_400.csv').TL8s1(indexOf(min(abs(time-t_acc))):indexOf(min(abs(time-t_recmd)))), ... 
    readtable('histories_short_print_400.csv').TL9s1(indexOf(min(abs(time-t_acc))):indexOf(min(abs(time-t_recmd)))), ...
    readtable('histories_short_print_400.csv').TL14s1(indexOf(min(abs(time-t_acc))):indexOf(min(abs(time-t_recmd))))]
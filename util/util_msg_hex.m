function msg_hex = util_msg_hex()
  msg_2B = ['04'; '02';];
  msg_4B = ['04'; '02'; '00'; '2e';];
  msg_8B = ['04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd';];
  msg_100B = ['04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd'; '37'; 'a6'; '00'; '20'; 'd6'; '01'; '3c'; 'f1'; '00'; '60'; '08'; 'ad'; '3b'; 'af'; '00'; '00'; '4a'; '6f'; '79'; '2c'; '20'; '62'; '72'; '69'; '67'; '68'; '74'; '20'; '73'; '70'; '61'; '72'; '6b'; '20'; '6f'; '66'; '20'; '64'; '69'; '76'; '69'; '6e'; '69'; '74'; '79'; '2c'; '0a'; '44'; '61'; '75'; '67'; '68'; '74'; '65'; '72'; '20'; '6f'; '66'; '20'; '45'; '6c'; '79'; '73'; '69'; '75'; '6d'; '2c'; '0a'; '46'; '69'; '72'; '65'; '2d'; '69'; '6e'; '73'; '69'; '72'; '65'; '64'; '20'; '77'; '65'; '20'; '74'; '72'; '65'; '61'; 'da'; '57'; '99'; 'ed'];
  msg_200B = ['04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd'; '37'; 'a6'; '00'; '20'; 'd6'; '01'; '3c'; 'f1'; '00'; '60'; '08'; 'ad'; '3b'; 'af'; '00'; '00'; '4a'; '6f'; '79'; '2c'; '20'; '62'; '72'; '69'; '67'; '68'; '74'; '20'; '73'; '70'; '61'; '72'; '6b'; '20'; '6f'; '66'; '20'; '64'; '69'; '76'; '69'; '6e'; '69'; '74'; '79'; '2c'; '0a'; '44'; '61'; '75'; '67'; '68'; '74'; '65'; '72'; '20'; '6f'; '66'; '20'; '45'; '6c'; '79'; '73'; '69'; '75'; '6d'; '2c'; '0a'; '46'; '69'; '72'; '65'; '2d'; '69'; '6e'; '73'; '69'; '72'; '65'; '64'; '20'; '77'; '65'; '20'; '74'; '72'; '65'; '61'; 'da'; '57'; '99'; 'ed'; '04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd'; '37'; 'a6'; '00'; '20'; 'd6'; '01'; '3c'; 'f1'; '00'; '60'; '08'; 'ad'; '3b'; 'af'; '00'; '00'; '4a'; '6f'; '79'; '2c'; '20'; '62'; '72'; '69'; '67'; '68'; '74'; '20'; '73'; '70'; '61'; '72'; '6b'; '20'; '6f'; '66'; '20'; '64'; '69'; '76'; '69'; '6e'; '69'; '74'; '79'; '2c'; '0a'; '44'; '61'; '75'; '67'; '68'; '74'; '65'; '72'; '20'; '6f'; '66'; '20'; '45'; '6c'; '79'; '73'; '69'; '75'; '6d'; '2c'; '0a'; '46'; '69'; '72'; '65'; '2d'; '69'; '6e'; '73'; '69'; '72'; '65'; '64'; '20'; '77'; '65'; '20'; '74'; '72'; '65'; '61'; 'da'; '57'; '99'; 'ed'];
  msg_206B = ['04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd'; '37'; 'a6'; '00'; '20'; 'd6'; '01'; '3c'; 'f1'; '00'; '60'; '08'; 'ad'; '3b'; 'af'; '00'; '00'; '4a'; '6f'; '79'; '2c'; '20'; '62'; '72'; '69'; '67'; '68'; '74'; '20'; '73'; '70'; '61'; '72'; '6b'; '20'; '6f'; '66'; '20'; '64'; '69'; '76'; '69'; '6e'; '69'; '74'; '79'; '2c'; '0a'; '44'; '61'; '75'; '67'; '68'; '74'; '65'; '72'; '20'; '6f'; '66'; '20'; '45'; '6c'; '79'; '73'; '69'; '75'; '6d'; '2c'; '0a'; '46'; '69'; '72'; '65'; '2d'; '69'; '6e'; '73'; '69'; '72'; '65'; '64'; '20'; '77'; '65'; '20'; '74'; '72'; '65'; '61'; 'da'; '57'; '99'; 'ed'; '04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd'; '37'; 'a6'; '00'; '20'; 'd6'; '01'; '3c'; 'f1'; '00'; '60'; '08'; 'ad'; '3b'; 'af'; '00'; '00'; '4a'; '6f'; '79'; '2c'; '20'; '62'; '72'; '69'; '67'; '68'; '74'; '20'; '73'; '70'; '61'; '72'; '6b'; '20'; '6f'; '66'; '20'; '64'; '69'; '76'; '69'; '6e'; '69'; '74'; '79'; '2c'; '0a'; '44'; '61'; '75'; '67'; '68'; '74'; '65'; '72'; '20'; '6f'; '66'; '20'; '45'; '6c'; '79'; '73'; '69'; '75'; '6d'; '2c'; '0a'; '46'; '69'; '72'; '65'; '2d'; '69'; '6e'; '73'; '69'; '72'; '65'; '64'; '20'; '77'; '65'; '20'; '74'; '72'; '65'; '61'; 'da'; '57'; '99'; 'ed'; '64'; '20'; '77'; '65'; '20'; '74'];
  msg_208B = ['04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd'; '37'; 'a6'; '00'; '20'; 'd6'; '01'; '3c'; 'f1'; '00'; '60'; '08'; 'ad'; '3b'; 'af'; '00'; '00'; '4a'; '6f'; '79'; '2c'; '20'; '62'; '72'; '69'; '67'; '68'; '74'; '20'; '73'; '70'; '61'; '72'; '6b'; '20'; '6f'; '66'; '20'; '64'; '69'; '76'; '69'; '6e'; '69'; '74'; '79'; '2c'; '0a'; '44'; '61'; '75'; '67'; '68'; '74'; '65'; '72'; '20'; '6f'; '66'; '20'; '45'; '6c'; '79'; '73'; '69'; '75'; '6d'; '2c'; '0a'; '46'; '69'; '72'; '65'; '2d'; '69'; '6e'; '73'; '69'; '72'; '65'; '64'; '20'; '77'; '65'; '20'; '74'; '72'; '65'; '61'; 'da'; '57'; '99'; 'ed'; '04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd'; '37'; 'a6'; '00'; '20'; 'd6'; '01'; '3c'; 'f1'; '00'; '60'; '08'; 'ad'; '3b'; 'af'; '00'; '00'; '4a'; '6f'; '79'; '2c'; '20'; '62'; '72'; '69'; '67'; '68'; '74'; '20'; '73'; '70'; '61'; '72'; '6b'; '20'; '6f'; '66'; '20'; '64'; '69'; '76'; '69'; '6e'; '69'; '74'; '79'; '2c'; '0a'; '44'; '61'; '75'; '67'; '68'; '74'; '65'; '72'; '20'; '6f'; '66'; '20'; '45'; '6c'; '79'; '73'; '69'; '75'; '6d'; '2c'; '0a'; '46'; '69'; '72'; '65'; '2d'; '69'; '6e'; '73'; '69'; '72'; '65'; '64'; '20'; '77'; '65'; '20'; '74'; '72'; '65'; '61'; 'da'; '57'; '99'; 'ed'; '64'; '20'; '77'; '65'; '20'; '74'; '2c'; 'c2'];
  msg_210B = ['04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd'; '37'; 'a6'; '00'; '20'; 'd6'; '01'; '3c'; 'f1'; '00'; '60'; '08'; 'ad'; '3b'; 'af'; '00'; '00'; '4a'; '6f'; '79'; '2c'; '20'; '62'; '72'; '69'; '67'; '68'; '74'; '20'; '73'; '70'; '61'; '72'; '6b'; '20'; '6f'; '66'; '20'; '64'; '69'; '76'; '69'; '6e'; '69'; '74'; '79'; '2c'; '0a'; '44'; '61'; '75'; '67'; '68'; '74'; '65'; '72'; '20'; '6f'; '66'; '20'; '45'; '6c'; '79'; '73'; '69'; '75'; '6d'; '2c'; '0a'; '46'; '69'; '72'; '65'; '2d'; '69'; '6e'; '73'; '69'; '72'; '65'; '64'; '20'; '77'; '65'; '20'; '74'; '72'; '65'; '61'; 'da'; '57'; '99'; 'ed'; '04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd'; '37'; 'a6'; '00'; '20'; 'd6'; '01'; '3c'; 'f1'; '00'; '60'; '08'; 'ad'; '3b'; 'af'; '00'; '00'; '4a'; '6f'; '79'; '2c'; '20'; '62'; '72'; '69'; '67'; '68'; '74'; '20'; '73'; '70'; '61'; '72'; '6b'; '20'; '6f'; '66'; '20'; '64'; '69'; '76'; '69'; '6e'; '69'; '74'; '79'; '2c'; '0a'; '44'; '61'; '75'; '67'; '68'; '74'; '65'; '72'; '20'; '6f'; '66'; '20'; '45'; '6c'; '79'; '73'; '69'; '75'; '6d'; '2c'; '0a'; '46'; '69'; '72'; '65'; '2d'; '69'; '6e'; '73'; '69'; '72'; '65'; '64'; '20'; '77'; '65'; '20'; '74'; '72'; '65'; '61'; 'da'; '57'; '99'; 'ed'; '64'; '20'; '77'; '65'; '20'; '74'; 'aa'; 'bb'; 'cc'; 'dd'];


  %msg_hex = {msg_208B};
  msg_hex = {msg_200B msg_206B msg_208B};
end


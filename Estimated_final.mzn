% Use this editor as a MiniZinc scratch book
include "alldifferent.mzn";
% the nutrients present in our food menu that we want to provide
int: min_energy; 
int: min_protein; 
int: max_salt; 
int: max_fat; 

int: number_of_foods; % total number of foods

 % a variable which we consider as a taste value to ensure providing the tasty food according to student's choice   
int: highest_taste;

int: total_student;% total number of students 


  
set of int: FOODS = 1..number_of_foods; % the set of total number of foods 
array[FOODS] of string: name_of_foods;  % an array containing all the foods name
array[FOODS] of int: energy; % an array containing total energy in each food
array[FOODS] of int: protein; %an array containing total protein in each food
array[FOODS] of int: salt; % an array containing total salt in each item
array[FOODS] of int: fat; % an array containing total fat in each food
array[FOODS] of int: cost; % an array containing total cost of each food
array[1..total_student,FOODS] of int: student_choice ; % 2d array containing total number of students and food name according to the student's choice value
    
set of int: DAYS = 1..7; % considering 1 week
set of int: COURSE = 1..3; % considering three course such as breakfast,lunch & dinner 
array[DAYS] of string: day; % an array containing all the 7 days
array[COURSE] of string: course; % an array containing 3 courses

set of FOODS: desserts; %considering desserts as dessert items set
set of FOODS: mains; %considering mains as main dish set
set of FOODS: sides; % %considering sides as side items set

var int: budget; 
var int: object;
var int: total;

array[DAYS,COURSE] of var int: maintaste; % 2d array containing the taste value for mains on each day & each course 
array[DAYS,COURSE] of var int: sidetaste; % 2d array containing the taste value for sides on each day & each course
array[DAYS,COURSE] of var int: desserttaste; % 2d array containing the taste value for desserts on each day & each course

array[DAYS,COURSE] of var int: mainroutine; 
array[DAYS,COURSE] of var int: sideroutine;
array[DAYS,COURSE] of var int: dessertroutine;
array[DAYS,COURSE] of var int: taste;
array[DAYS,COURSE] of var int: money; %2d array showing the total money needed for each day & each course

      
constraint 
  forall(i in DAYS)(
    forall(j in COURSE)(
      mainroutine[i,j] in mains
      /\
      sideroutine[i,j] in sides
      /\ 
      dessertroutine[i,j] in desserts
      /\ 
      energy[mainroutine[i,j]] + energy[sideroutine[i,j]] + energy[dessertroutine[i,j]] >=min_energy % total energy in a course should be greater than the given minimum energy
      /\
      protein[mainroutine[i,j]]+protein[sideroutine[i,j]]+protein[dessertroutine[i,j]] >=min_protein % total protein in a course should be greater than the given minimum protein
      /\
      salt[mainroutine[i,j]] + salt[sideroutine[i,j]] + salt[dessertroutine[i,j]] <= max_salt % total salt in a course should be less than the given minimum salt
      /\
      fat[mainroutine[i,j]] + fat[sideroutine[i,j]] + fat[dessertroutine[i,j]] <= max_fat % total fat in a course should be less than the given minimum fat
      /\
      money[i,j]=(cost[mainroutine[i,j]] + cost[sideroutine[i,j]] + cost[dessertroutine[i,j]])  % total money is the sum of the cost of each course
      /\
      taste[i,j]=((maintaste[i,j]=sum(k in 1..total_student)(student_choice[k,(mainroutine[i,j])]))
      +
      (sidetaste[i,j]=sum(k in 1..total_student)(student_choice[k,sideroutine[i,j]])) 
      +
      (desserttaste[i,j]=sum(k in 1..total_student)(student_choice[k,dessertroutine[i,j]])
      ))
    )
   );
% condition here is that dessert item , main dish and side item should always be different for each course in a day
constraint forall(i in 1..7)(
              (alldifferent(j in 1..3)(dessertroutine[i,j]))/\ 
              (alldifferent(j in 1..3)(sideroutine[i,j]))/\ 
              (alldifferent(j in 1..3)(mainroutine[i,j]))              
              ); 
% condition here is that no two same dessert item/main/side dish will be given two days in a row              
constraint forall(i in 1..6)(
                forall(j in 1..3)(
                  dessertroutine[i,j] != dessertroutine[i+1,j]/\
                  sideroutine[i,j] != sideroutine[i+1,j]/\
                  mainroutine[i,j] != mainroutine[i+1,j]
                )              
              ); 
              
constraint total=sum(i in DAYS, j in COURSE)(money[i,j]);
constraint total <= (budget*total_student); % total money should be less or equal to the budget fixed for per student 

solve minimize sum(i in DAYS, j in COURSE)(taste[i,j]);


output [if (j==1 /\ i==1) then ("total money: "++show(total)++"\n") else "" endif ++if j==1 then ("||"++day[fix(i)]++"||") else " " endif ++"\n"++course[fix(j)] ++ ": Main:"++name_of_foods[fix(mainroutine[i,j])] ++", Side:"++name_of_foods[fix(sideroutine[i,j])] ++", Dessert:"++name_of_foods[fix(dessertroutine[i,j])] ++if j==3 then "\n" else " " endif | i in DAYS, j in COURSE ];

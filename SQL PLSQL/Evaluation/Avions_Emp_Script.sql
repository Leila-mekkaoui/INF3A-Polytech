-- Scrip de création de tables TP Avions Emp

DROP TABLE PILOTE;
DROP TABLE AVION;
DROP TABLE VOL;
CREATE TABLE PILOTE
    (
    PLNUM NUMBER(4),
    PLNOM VARCHAR2(15),
    PLPRENOM VARCHAR2(15),
    VILLE VARCHAR2(15),
    SALAIRE NUMBER(7,2)
    );

CREATE TABLE AVION
    (
    AVNUM NUMBER(4),
    AVNOM VARCHAR2(8),
    CAPACITE NUMBER(4),
    LOCALISATION VARCHAR2(9)
    );

CREATE TABLE VOL
    (
    VOLNUM NUMBER(3),
    PLNUM NUMBER(4),
    AVNUM NUMBER(4),
    VILLEDEP VARCHAR2(15),
    VILLEARR VARCHAR2(15),
    HEUREDEP DATE,
    HEUREARR  DATE
    );

insert into PILOTE values
(1,'MIRANDA','SERGE','PARIS',21000.00);
insert into PILOTE values
(2,'LETHANH','NAHN','TOULOUSE',21000.00);
insert into PILOTE values
(3,'TALADOIRE','GILLES','NICE',18000.00);
insert into PILOTE values
(4,'CHARBONNIER','ANNETTE','PARIS',17000.00);
insert into PILOTE values
(5,'REY','CHRISTOPHE','TOULOUSE',19000.00);
insert into PILOTE values
(6,'CHARBONNIER','FABIEN','PARIS',18000.00);
insert into PILOTE values
(7,'PENAULD','PIERRE','NICE',17000.00);
insert into PILOTE values
(8,'FOUILHOUX','PIERRE','LYON',15000.00);
insert into PILOTE values
(9,'GANNAT','CHRISTOPHE',NULL,18000.00);
insert into PILOTE values
(10,'GADAIX','SONIA','PARIS',20000.00);
insert into AVION values
(1,'A300',300,'NICE');
insert into AVION values
(2,'A310',300,'NICE');
insert into AVION values
(3,'B707',250,'PARIS');
insert into AVION values
(4,'A300',280,'LYON');
insert into AVION values
(5,'CONCORDE',160,'NICE');
insert into AVION values
(6,'B747',460,'PARIS');
insert into AVION values
(7,'B707',250,'PARIS');
insert into AVION values
(8,'A310',300,'TOULOUSE');
insert into AVION values
(9,'MERCURE',180,'LYON');
insert into AVION values
(10,'CONCORDE',160,'PARIS');


insert into VOL values
(100,1,1,'NICE','TOULOUSE',to_date('1100','HH24:MI'),to_date('1230','HH24:MI'));
insert into VOL values (101,1,8,'PARIS','TOULOUSE',to_date('1700','HH24:MI'),to_date('1830','HH24:MI'));
insert into VOL values
(102,2,1,'TOULOUSE','LYON',to_date('1400','HH24:MI'),to_date('1600','HH24:MI'));
insert into VOL values (103,5,3,'TOULOUSE','LYON',to_date('1800','HH24:MI'),to_date('2000','HH24:MI'));
insert into VOL values
(104,9,1,'PARIS','NICE',to_date('0645','HH24:MI'),to_date('0815','HH24:MI'));
insert into VOL values
(105,10,2,'LYON','NICE',to_date('1100','HH24:MI'),to_date('1200','HH24:MI'));
insert into VOL values
(106,1,4,'PARIS','LYON',to_date('0800','HH24:MI'),to_date('0900','HH24:MI'));
insert into VOL values
(107,8,4,'NICE','PARIS',to_date('0715','HH24:MI'),to_date('0845','HH24:MI'));
insert into VOL values
(108,1,8,'NANTES','LYON',to_date('0900','HH24:MI'),to_date('1530','HH24:MI'));
insert into VOL values
(109,8,2,'NICE','PARIS',to_date('1215','HH24:MI'),to_date('1345','HH24:MI'));
insert into VOL values
(110,9,2,'PARIS','LYON',to_date('1500','HH24:MI'),to_date('1600','HH24:MI'));
insert into VOL values
(111,1,2,'LYON','NANTES',to_date('1630','HH24:MI'),to_date('2000','HH24:MI'));
insert into VOL values
(112,4,5,'NICE','LENS',to_date('1100','HH24:MI'),to_date('1400','HH24:MI'));
insert into VOL values
(113,3,5,'LENS','PARIS',to_date('1500','HH24:MI'),to_date('1600','HH24:MI'));
insert into VOL values
(114,8,9,'PARIS','TOULOUSE',to_date('1700','HH24:MI'),to_date('1800','HH24:MI'));
insert into VOL values (115,7,5,'PARIS','TOULOUSE',to_date('1800','HH24:MI'),to_date('1900','HH24:MI'));

COMMIT;




------------------------------------------------------------------------------------------------------------

-- EMP et Dept


DROP TABLE DEPT;
DROP TABLE EMP;

CREATE TABLE DEPT
    (
    DEPTNO NUMBER(2) CONSTRAINT PK_DEPT PRIMARY KEY,
    DNAME VARCHAR2(14),
    LOC VARCHAR2(13)
    );

CREATE TABLE EMP
    (
    EMPNO NUMBER(4), 
    ENAME VARCHAR2(10),
    JOB VARCHAR2(9),
    MGR NUMBER(4),
    HIREDATE DATE,
    SAL NUMBER(7,2),
    COMM NUMBER(7,2),
    DEPTNO NUMBER(2)
    );


INSERT INTO DEPT VALUES
(10,'ACCOUNTING','NEW YORK');
INSERT INTO DEPT VALUES
(20,'RESEARCH','DALLAS');
INSERT INTO DEPT VALUES
(30,'SALES','CHICAGO');
INSERT INTO DEPT VALUES
(40,'OPERATIONS','BOSTON');


INSERT INTO EMP VALUES
(7369,'SMITH','CLERK',7902,to_date('17-12-1980','dd-mm-yyyy'),800,NULL,20);
INSERT INTO EMP VALUES
(7499,'ALLEN','SALESMAN',7698,to_date('20-02-1981','dd-mm-yyyy'),1600,300,30);
INSERT INTO EMP VALUES
(7521,'WARD','SALESMAN',7698,to_date('22-02-1981','dd-mm-yyyy'),1250,500,30);
INSERT INTO EMP VALUES
(7566,'JONES','MANAGER',7839,to_date('02-04-1981','dd-mm-yyyy'),2975,NULL,20);
INSERT INTO EMP VALUES
(7654,'MARTIN','SALESMAN',7698,to_date('28-09-1981','dd-mm-yyyy'),1250,1400,30);
INSERT INTO EMP VALUES
(7698,'BLAKE','MANAGER',7839,to_date('01-05-1981','dd-mm-yyyy'),2850,NULL,30);
INSERT INTO EMP VALUES
(7782,'CLARK','MANAGER',7839,to_date('09-06-1981','dd-mm-yyyy'),2450,NULL,10);
INSERT INTO EMP VALUES
(7788,'SCOTT','ANALYST',7566,to_date('13-07-1987','dd-mm-yyyy')-85,3000,NULL,20);
INSERT INTO EMP VALUES
(7839,'KING','PRESIDENT',NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10);
INSERT INTO EMP VALUES
(7844,'TURNER','SALESMAN',7698,to_date('08-09-1981','dd-mm-yyyy'),1500,0,30);
INSERT INTO EMP VALUES
(7876,'ADAMS','CLERK',7788,to_date('13-07-1987', 'dd-mm-yyyy')-51,1100,NULL,20);
INSERT INTO EMP VALUES
(7900,'JAMES','CLERK',7698,to_date('03-12-1981','dd-mm-yyyy'),950,NULL,30);
INSERT INTO EMP VALUES
(7902,'FORD','ANALYST',7566,to_date('03-12-1981','dd-mm-yyyy'),3000,NULL,20);
INSERT INTO EMP VALUES
(7934,'MILLER','CLERK',7782,to_date('23-01-1982','dd-mm-yyyy'),1300,NULL,10);




COMMIT;



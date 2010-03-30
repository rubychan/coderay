/* This is a modified copy of the
  query linked above to test other keywords: */ 
SELECT   sd.qbclass,                   -- Comments Test
         Sum(sd.amount)   AS invoiceamount,          # Comments Test
         Sum(scd1.amount) AS paymentsperiod1, 
         Sum(scd2.amount) AS paymentsperiod2, 
         Sum(scd3.amount) AS paymentsperiod3 
FROM     studentdebit AS sd 
         LEFT JOIN (SELECT studentcreditdetail.studentdebitid, 
                           studentcreditdetail.amount, 
                           studentcredit.date, 
                           credittype.credittype 
                    FROM   studentcreditdetail 
                           INNER JOIN studentcredit 
                             ON studentcreditdetail.studentcreditid = studentcredit.studentcreditid 
                                AND studentcredit.obsolete = 0 /* Not Deleted */ 
                                AND studentcredit.status = 1   /* Successful  */ 
                                /* PERIOD 1 */ 
                                AND studentcredit.date < Now() 
                                /* PERIOD 1 */ 
                                AND studentcredit.date > Now() - INTERVAL 1 MONTH 
                           LEFT JOIN credittype 
                             USING(credittypeid)) AS scd1 
           ON sd.studentdebitid = scd1.studentdebitid 
         LEFT JOIN (SELECT studentcreditdetail.studentdebitid, 
                           studentcreditdetail.amount, 
                           studentcredit.date, 
                           credittype.credittype 
                    FROM   studentcreditdetail 
                           INNER JOIN studentcredit 
                             ON studentcreditdetail.studentcreditid = studentcredit.studentcreditid 
                                AND studentcredit.obsolete = 0 /* Not Deleted */ 
                                AND studentcredit.status = 1   /* Successful  */ 
                                /* PERIOD 2 */ 
                                AND studentcredit.date < Now() - INTERVAL 1 MONTH 
                                /* PERIOD 2 */ 
                                AND studentcredit.date > Now() - INTERVAL 2 MONTH 
                           LEFT OUTER JOIN credittype 
                             USING(credittypeid)) AS scd2 
           ON sd.studentdebitid = scd2.studentdebitid 
         RIGHT JOIN (SELECT studentcreditdetail.studentdebitid, 
                           studentcreditdetail.amount, 
                           studentcredit.date, 
                           credittype.credittype 
                    FROM   studentcreditdetail 
                           INNER JOIN studentcredit 
                             ON studentcreditdetail.studentcreditid = studentcredit.studentcreditid 
                                AND studentcredit.obsolete = 0 /* Not Deleted */ 
                                AND studentcredit.status = 1   /* Successful  */ 
                                /* PERIOD 3 */ 
                                AND studentcredit.date < Now() - INTERVAL 2 MONTH 
                                /* PERIOD 3 */ 
                                AND studentcredit.date > Now() - INTERVAL 3 MONTH 
                           LEFT JOIN credittype 
                             USING(credittypeid)) AS scd3 
           ON sd.studentdebitid = scd3.studentdebitid 
WHERE    sd.obsolete = 0   /* Not Deleted */ 
         AND sd.status = 0 /* Normal      */ 
         /* Exclude Voided Invoices */ 
         AND sd.adjustsdebitid IS NULL 
         AND sd.studentdebitid NOT IN (SELECT adjustsdebitid 
                                       FROM   studentdebit 
                                       WHERE  adjustsdebitid IS NOT NULL) 
         /* FULL PERIOD */ 
         AND sd.DATE < Now() 
         /* FULL PERIOD */ 
         AND sd.DATE > Now() - INTERVAL 3 MONTH 
GROUP BY sd.qbclass 
/* Formatting only */ 
UNION ALL 
SELECT '---', 
       '---', 
       '---', 
       '---', 
       '---' 
/* Payment Types Summary */ 
UNION DISTINCT 
SELECT   credittype, 
         invoiceamount, 
         Sum(paymentsperiod1), 
         Sum(paymentsperiod2), 
         Sum(paymentsperiod3) 
FROM     (SELECT   scd.credittype, 
                   ''              AS invoiceamount, 
                   Sum(scd.amount) AS paymentsperiod1, 
                   ''              AS paymentsperiod2, 
                   ''              AS paymentsperiod3 
          FROM     studentdebit AS sd 
                   INNER JOIN (SELECT studentcreditdetail.studentdebitid, 
                                      studentcreditdetail.amount, 
                                      studentcredit.date, 
                                      credittype.credittype 
                               FROM   studentcreditdetail 
                                      INNER JOIN studentcredit 
                                        ON studentcreditdetail.studentcreditid = studentcredit.studentcreditid 
                                           AND studentcredit.obsolete = 0 /* Not Deleted */ 
                                           AND studentcredit.status = 1   /* Successful  */ 
                                           /* PERIOD 1 */ 
                                           AND studentcredit.date < Now() 
                                           /* PERIOD 1 */ 
                                           AND studentcredit.date > Now() - INTERVAL 1 MONTH 
                                      LEFT JOIN credittype 
                                        USING(credittypeid)) AS scd 
                     ON sd.studentdebitid = scd.studentdebitid 
          WHERE    sd.obsolete = 0   /* Not Deleted */ 
                   AND sd.status = 0 /* Normal      */ 
                   /* Exclude Voided Invoices */ 
                   AND sd.adjustsdebitid IS NULL 
                   AND sd.studentdebitid NOT IN (SELECT adjustsdebitid 
                                                 FROM   studentdebit 
                                                 WHERE  adjustsdebitid IS NOT NULL) 
                   AND sd.DATE < Now() 
                   AND sd.DATE > Now() - INTERVAL 3 MONTH 
          GROUP BY scd.credittype 
          UNION ALL 
          SELECT   scd.credittype, 
                   ''              AS invoiceamount, 
                   ''              AS paymentsperiod1, 
                   Sum(scd.amount) AS paymentsperiod2, 
                   ''              AS paymentsperiod3 
          FROM     studentdebit AS sd 
                   INNER JOIN (SELECT studentcreditdetail.studentdebitid, 
                                      studentcreditdetail.amount, 
                                      studentcredit.date, 
                                      credittype.credittype 
                               FROM   studentcreditdetail 
                                      INNER JOIN studentcredit 
                                        ON studentcreditdetail.studentcreditid = studentcredit.studentcreditid 
                                           AND studentcredit.obsolete = 0 /* Not Deleted */ 
                                           AND studentcredit.status = 1   /* Successful  */ 
                                           /* PERIOD 2 */ 
                                           AND studentcredit.date < Now() - INTERVAL 1 MONTH 
                                           /* PERIOD 2 */ 
                                           AND studentcredit.date > Now() - INTERVAL 2 MONTH 
                                      LEFT JOIN credittype 
                                        USING(credittypeid)) AS scd 
                     ON sd.studentdebitid = scd.studentdebitid 
          WHERE    sd.obsolete = 0   /* Not Deleted */ 
                   AND sd.status = 0 /* Normal      */ 
                   /* Exclude Voided Invoices */ 
                   AND sd.adjustsdebitid IS NULL 
                   AND sd.studentdebitid NOT IN (SELECT adjustsdebitid 
                                                 FROM   studentdebit 
                                                 WHERE  adjustsdebitid IS NOT NULL) 
                   AND sd.DATE < Now() 
                   AND sd.DATE > Now() - INTERVAL 3 MONTH 
          GROUP BY scd.credittype 
          UNION ALL 
          SELECT   scd.credittype, 
                   ''              AS invoiceamount, 
                   ''              AS paymentsperiod1, 
                   ''              AS paymentsperiod2, 
                   Sum(scd.amount) AS paymentsperiod3 
          FROM     studentdebit AS sd 
                   INNER JOIN (SELECT studentcreditdetail.studentdebitid, 
                                      studentcreditdetail.amount, 
                                      studentcredit.date, 
                                      credittype.credittype 
                               FROM   studentcreditdetail 
                                      INNER JOIN studentcredit 
                                        ON studentcreditdetail.studentcreditid = studentcredit.studentcreditid 
                                           AND studentcredit.obsolete = 0 /* Not Deleted */ 
                                           AND studentcredit.status = 1   /* Successful  */ 
                                           /* PERIOD 3 */ 
                                           AND studentcredit.date < Now() - INTERVAL 2 MONTH 
                                           /* PERIOD 3 */ 
                                           AND studentcredit.date > Now() - INTERVAL 3 MONTH 
                                      LEFT JOIN credittype 
                                        USING(credittypeid)) AS scd 
                     ON sd.studentdebitid = scd.studentdebitid 
          WHERE    sd.obsolete = 0   /* Not Deleted */ 
                   AND sd.status = 0 /* Normal      */ 
                   /* Exclude Voided Invoices */ 
                   AND sd.adjustsdebitid IS NULL 
                   AND sd.studentdebitid NOT IN (SELECT adjustsdebitid 
                                                 FROM   studentdebit 
                                                 WHERE  adjustsdebitid IS NOT NULL) 
                   AND sd.date < Now() 
                   AND sd.date > Now() - INTERVAL 3 MONTH 
          GROUP BY scd.credittype) AS ct 
GROUP BY ct.credittype

SELECT 'mediaid'             AS `idtype`, 
       `m`.`mediaid`         AS `id`, 
       `m`.`title`           AS `title`, 
       `m`.`description`     AS `description`, 
       `m`.`source`          AS `source`, 
       `m`.`date`            AS `startdate`, 
       `m`.`date`            AS `enddate`, 
       `c`.`class`           AS `class`, 
       `c`.`classname`       AS `classname`, 
       `per`.`firstname`     AS `firstname`, 
       `per`.`lastname`      AS `lastname`, 
       `c`.`description`     AS `classdesc`, 
       `p`.`programid`       AS `programid`, 
       If((`p`.`subprogramof` IS NOT NULL),`mp`.`programname`, 
          `p`.`programname`) AS `programname`, 
       'Recorded'            AS `longname` 
FROM   ((((((((`media` `m` 
               JOIN `mediaaudience` `ma` 
                 ON (((`m`.`mediaid` = `ma`.`mediaid`) 
                      AND (`ma`.`audiencetype` = 'Public') 
                      AND ((`ma`.`enddate` < Now()) 
                            OR Isnull(`ma`.`enddate`))))) 
              LEFT JOIN `mediapresenter` `mpp` 
                ON ((`m`.`mediaid` = `mpp`.`mediaid`))) 
             LEFT JOIN `person` `per` 
               ON ((`mpp`.`personid` = `per`.`personid`))) 
            LEFT JOIN `mediaaudience` `mad` 
              ON (((`ma`.`mediaid` = `mad`.`mediaid`) 
                   AND (`mad`.`audiencetype` = 'classid')))) 
           LEFT JOIN `class` `c` 
             ON ((`mad`.`audienceid` = `c`.`classid`))) 
          LEFT JOIN `program_class` `pc` 
            ON ((`c`.`classid` = `pc`.`classid`))) 
         LEFT JOIN `program` `p` 
           ON ((`pc`.`programid` = `p`.`programid`))) 
        LEFT JOIN `program` `mp` 
          ON ((`p`.`subprogramof` = `mp`.`programid`))) 
UNION 
SELECT 'sectionid'           AS `idtype`, 
       `cc`.`sectionid`      AS `id`, 
       `cc`.`title`          AS `title`, 
       `cc`.`description`    AS `description`, 
       `l`.`mapurl`          AS `mapurl`, 
       `cc`.`starttime`      AS `startdate`, 
       `cc`.`endtime`        AS `enddate`, 
       `c`.`class`           AS `class`, 
       `c`.`classname`       AS `classname`, 
       `per`.`firstname`     AS `firstname`, 
       `per`.`lastname`      AS `lastname`, 
       `c`.`description`     AS `classdesc`, 
       `p`.`programid`       AS `programid`, 
       If((`p`.`subprogramof` IS NOT NULL),`mp`.`programname`, 
          `p`.`programname`) AS `programname`, 
       `d`.`longname`        AS `longname` 
FROM   ((((((((`calendarcache` `cc` 
               JOIN `section` `s` 
                 ON ((`cc`.`sectionid` = `s`.`sectionid`))) 
              LEFT JOIN `person` `per` 
                ON ((`s`.`teacherid` = `per`.`personid`))) 
             LEFT JOIN `division` `d` 
               ON ((`s`.`divisionid` = `d`.`divisionid`))) 
            LEFT JOIN `location` `l` 
              ON ((`s`.`locationid` = `l`.`locationid`))) 
           LEFT JOIN `class` `c` 
             ON ((`s`.`classid` = `c`.`classid`))) 
          LEFT JOIN `program_class` `pc` 
            ON ((`c`.`classid` = `pc`.`classid`))) 
         LEFT JOIN `program` `p` 
           ON ((`pc`.`programid` = `p`.`programid`))) 
        LEFT JOIN `program` `mp` 
          ON ((`p`.`subprogramof` = `mp`.`programid`))) 
WHERE  (NOT ((`cc`.`description` LIKE '%{cs}%')))
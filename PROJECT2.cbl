      ******************************************************************
      * Author: ZHAO, LingFeng; CHENG, Annabel
      * StudentID: 041162790; 041146557.
      * Course and Section: CST8283 311
      * Date: 2025-07-15
      * Purpose: PROJECT2 INVESTMENT PORTFOLIO MANAGEMENT PROGRAM
      * Tectonics: cobc
      ******************************************************************
       IDENTIFICATION DIVISION.
      ******************************************************************
       PROGRAM-ID. PROJECT2.
      ******************************************************************
       ENVIRONMENT DIVISION.
      ******************************************************************
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT STOCKS-FILE
             ASSIGN TO "../STOCKS.TXT"
             ORGANIZATION IS LINE SEQUENTIAL.
           SELECT PORTFOLIO-FILE
             ASSIGN TO "../PORTFOLIO.TXT"
             ORGANIZATION IS LINE SEQUENTIAL.
           SELECT REPORT-FILE
             ASSIGN TO "../REPORT.TXT"
             ORGANIZATION IS LINE SEQUENTIAL.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       FILE SECTION.
       FD PORTFOLIO-FILE.
       *> A record from the portfolio file containing stock symbol, shares, and average cost.
       01 PORTFOLIO-RECORD.
           05 P-STOCK-SYMBOL           PIC X(07).
           05 P-SHARES                 PIC 9(05).
           05 P-AVG-COST               PIC 9(04)V99.

       FD STOCKS-FILE.
       *> A record from the stocks file containing stock symbol, name, and closing price.
       01 STOCKS-RECORD.
           05 S-STOCK-SYMBOL           PIC X(07).
           05 S-STOCK-NAME             PIC X(25).
           05 S-CLOSING-PRICE          PIC 9(04)V99.

       FD REPORT-FILE.
       *> A line of the output report showing stock name, shares, costs, values, and gain/loss.
       01 REPORT-RECORD.
           05 R-STOCK-NAME             PIC X(25).
           05 FILLER                   PIC X(03) VALUE SPACES.
           05 R-SHARES                 PIC ZZ,ZZ9.
           05 FILLER                   PIC X(03) VALUE SPACES.
           05 R-AVG-COST               PIC $$,$$$,$$9.99.
           05 FILLER                   PIC X(03) VALUE SPACES.
           05 R-CLOSING-PRICE          PIC $$,$$$,$$9.99.
           05 FILLER                   PIC X(03) VALUE SPACES.
           05 R-COST-BASE              PIC $$,$$$,$$9.99.
           05 FILLER                   PIC X(03) VALUE SPACES.
           05 R-MARKET-VALUE           PIC $$,$$$,$$9.99.
           05 FILLER                   PIC X(03) VALUE SPACES.
           05 TOTAL-GAIN-LOSS          PIC $$,$$$,$$9.99-.


       WORKING-STORAGE SECTION.
       *> A simple counter or loop control variable, starting at 1.
       01 SUB-1                        PIC 9(03)  VALUE 1.

       *> End-of-file flag with condition names for better readability.
       01 EOF-FLAG                     PIC X(01)  VALUE 'N'.
           88 EOF-YES                             VALUE 'Y'.
           88 EOF-NO                              VALUE 'N'.

       *> Counter for number of records read.
       01 RECORDS-READ                 PIC 9(03)  VALUE ZERO.

       *> Counter for number of records written.
       01 RECORDS-WRITTEN              PIC 9(03)  VALUE ZERO.

       *> A line of dashes for report formatting.
       01 DASH-LINE                    PIC X(121) VALUE ALL "=".

       *> A blank line for spacing in the report.
       01 BLANK-LINE                   PIC X(121) VALUE ALL " ".

       *> Title for the report.
       01 HEADER1                      PIC X(50)  VALUE "STOCK REPORT".

       *> Secondary header line, contents set at runtime.
       01 HEADER2                      PIC X(121).

       *> Record control flag or switch (purpose defined in logic).
       01 RECORD-CTL                   PIC 9(01)  VALUE ZERO.

       *> Table to store up to 20 stock entries: symbol, name, and closing price.
       01 STOCKS-TABLE.
          05 STOCKS-VALUE OCCURS 20 TIMES.
             10 T-STOCK-SYMBOL         PIC X(07).
             10 T-STOCK-NAME           PIC X(25).
             10 T-CLOSING-PRICE        PIC 9(04)V99.

       *> Flag to indicate whether a stock was found.
       01  STOCK-FOUND-FLAG            PIC X(1) VALUE 'N'.
           88  STOCK-FOUND                      VALUE 'Y'.

       *> Temporary variable to hold the base cost of a stock.
       01 TEMP-COST-BASE               PIC 9(07)V99.
       *> Temporary variable to hold the market value of a stock.
       01 TEMP-MARKET-VALUE            PIC 9(07)V99.
       *> Temporary variable to hold calculated gain or loss.
       01 TEMP-GAIN-LOSS               PIC S9(07)V99.

       *> A line used for printing in the report.
       01 REPORT-LINE                  PIC X(80) VALUE SPACE.
       *> Formatted version of records read for report display.
       01 RECORDS-READ-PRINT           PIC ZZ9.
       *> Formatted version of records written for report display.
       01 RECORDS-WRITTEN-PRINT        PIC ZZ9.

      ******************************************************************
       PROCEDURE DIVISION.
      ******************************************************************
       100-PROCESS-DATA.
           PERFORM 210-INITIALISE-ROUTINE.
           PERFORM 220-PRODUCE-REPORT UNTIL EOF-YES.
           PERFORM 250-CLOSE-FILES.
           STOP RUN.

       210-INITIALISE-ROUTINE.
           PERFORM 310-OPEN-FILES.
           PERFORM 320-READ-STOCK-RECORDS
                   VARYING SUB-1 FROM 1 BY 1
                   UNTIL SUB-1 > 20 OR EOF-YES.

           SET EOF-NO TO TRUE.
           MOVE 0 TO RECORD-CTL.
           PERFORM 330-READ-PORTFOLIO-RECORDS.

       220-PRODUCE-REPORT.
           PERFORM 340-WRITE-HEADER.
           PERFORM 350-GENERATE-CONTENTS UNTIL EOF-YES.
           PERFORM 390-WRITE-FOOTER.

       250-CLOSE-FILES.
           CLOSE STOCKS-FILE  PORTFOLIO-FILE  REPORT-FILE.

       310-OPEN-FILES.
           OPEN INPUT  PORTFOLIO-FILE  STOCKS-FILE.
           OPEN OUTPUT REPORT-FILE.

       *> Load all stock data from STOCKS-FILE into memory for lookup.
       320-READ-STOCK-RECORDS.
           READ STOCKS-FILE
             AT END
               SET EOF-YES TO TRUE
               IF RECORD-CTL = 0
                  DISPLAY "NO DATA IN THE STOCKS FILE. "
               END-IF
             NOT AT END
               MOVE 1 TO RECORD-CTL
               PERFORM 410-LOAD-STOCKS-TABLE
           END-READ.

       *> Read each portfolio item, find the matching stock, and compute results.
       330-READ-PORTFOLIO-RECORDS.
           READ PORTFOLIO-FILE
             AT END
               SET EOF-YES TO TRUE
               IF RECORD-CTL = 0
                  DISPLAY "NO DATA IN THE PORTFOLIO FILE. "
               END-IF
             NOT AT END
               MOVE 1 TO RECORD-CTL
               ADD  1 TO RECORDS-READ
           END-READ.

       340-WRITE-HEADER.
           STRING
             "STOCK NAME                 #SHARES       UNIT COST"
             DELIMITED BY SIZE INTO HEADER2 (1:53)
           END-STRING.

           STRING
             "AT CLOSING       COST BASE    MARKET VALUE      GAIN/LOSS"
             DELIMITED BY SIZE INTO HEADER2 (57:)
           END-STRING.

           MOVE HEADER1   TO REPORT-RECORD.
           WRITE REPORT-RECORD.
           MOVE DASH-LINE TO REPORT-RECORD.
           WRITE REPORT-RECORD.
           MOVE HEADER2   TO REPORT-RECORD
           WRITE REPORT-RECORD.
           MOVE DASH-LINE TO REPORT-RECORD.
           WRITE REPORT-RECORD.

       *> Calculate cost base, market value, and gain/loss for each stock.
       350-GENERATE-CONTENTS.
           MOVE SPACES TO REPORT-RECORD.
           PERFORM 450-FIND-STOCK-INFO
                   VARYING SUB-1 FROM 1 BY 1
                   UNTIL STOCK-FOUND OR SUB-1 > 20.
           MOVE "N" TO STOCK-FOUND-FLAG.
           PERFORM 470-WRITE-STOCK-INFO.
           PERFORM 330-READ-PORTFOLIO-RECORDS.

       *> Write summary lines and closing section of the report.
       390-WRITE-FOOTER.
           MOVE DASH-LINE  TO REPORT-RECORD.
           WRITE REPORT-RECORD.

           MOVE BLANK-LINE TO REPORT-RECORD.
           WRITE REPORT-RECORD.

           MOVE RECORDS-READ    TO RECORDS-READ-PRINT.
           MOVE RECORDS-WRITTEN TO RECORDS-WRITTEN-PRINT.

           STRING
             "Records read:   "        DELIMITED BY SIZE
             RECORDS-READ-PRINT        DELIMITED BY SIZE
             "   Records written:   "  DELIMITED BY SIZE
             RECORDS-WRITTEN-PRINT     DELIMITED BY SIZE
             INTO REPORT-LINE.

           MOVE REPORT-LINE TO REPORT-RECORD.
           WRITE REPORT-RECORD.

           DISPLAY "RECORDS'VE SUCCESSFULLY BEEN WRITTEN TO THE FILE.".

       410-LOAD-STOCKS-TABLE.
           MOVE S-STOCK-SYMBOL   TO T-STOCK-SYMBOL(SUB-1).
           MOVE S-STOCK-NAME     TO T-STOCK-NAME(SUB-1).
           MOVE S-CLOSING-PRICE  TO T-CLOSING-PRICE(SUB-1).

       *> Search STOCKS-TABLE for a stock symbol that matches the portfolio entry.
       450-FIND-STOCK-INFO.
           IF T-STOCK-SYMBOL(SUB-1) EQUALS TO P-STOCK-SYMBOL
              MOVE T-STOCK-NAME(SUB-1)    TO R-STOCK-NAME
              MOVE T-CLOSING-PRICE(SUB-1) TO R-CLOSING-PRICE
              MOVE T-CLOSING-PRICE(SUB-1) TO TEMP-MARKET-VALUE
              SET STOCK-FOUND TO TRUE
           END-IF.

       *> Format and write detailed stock information to the report.
       470-WRITE-STOCK-INFO.
           MOVE P-SHARES   TO R-SHARES.
           MOVE P-AVG-COST TO R-AVG-COST.

           MULTIPLY P-AVG-COST BY P-SHARES GIVING TEMP-COST-BASE.
           MOVE TEMP-COST-BASE TO R-COST-BASE.

           MULTIPLY TEMP-MARKET-VALUE BY P-SHARES
                    GIVING TEMP-MARKET-VALUE.
           MOVE TEMP-MARKET-VALUE TO R-MARKET-VALUE.

           SUBTRACT TEMP-COST-BASE FROM TEMP-MARKET-VALUE
                    GIVING TEMP-GAIN-LOSS.
           MOVE TEMP-GAIN-LOSS TO TOTAL-GAIN-LOSS.
           WRITE REPORT-RECORD.

           ADD 1 TO RECORDS-WRITTEN.

      ******************************************************************
       END PROGRAM PROJECT2.
      ******************************************************************

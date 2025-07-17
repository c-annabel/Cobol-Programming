      ******************************************************************
      * Author: CHENG, Annabel
      * StudentID: 041146557.
      * Course and Section: CST8283 311
      * Date: 2025-07-07
      * Purpose: LAB 4 STOCK RECOMMENDATION
      *          1 means the stock is recommended as STRONG BUY.
      *          2 means BUY, and 3 means HOLD, 4 means SELL
      * Tectonics: cobc
      ******************************************************************
       IDENTIFICATION DIVISION.
      ******************************************************************
       PROGRAM-ID. LAB4.
      ******************************************************************
       ENVIRONMENT DIVISION.
      ******************************************************************
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT STOCKS-FILE
             ASSIGN TO "../STOCKS.TXT"
             ORGANIZATION IS LINE SEQUENTIAL.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       FILE SECTION.
       FD STOCKS-FILE.
       01 STOCKS-RECORD.
           05 S-STOCK-SYMBOL           PIC X(07).
           05 S-STOCK-NAME             PIC X(25).
           05 S-CLOSING-PRICE          PIC 9(04)V99.
           05 S-ANALYST-RECOMM         PIC 9(01).
              88 VALID-CODE                       VALUES 1 THROUGH 4.
              88 INVALID-CODE                     VALUES 5 THROUGH 9.

       WORKING-STORAGE SECTION.
       01 SUB-1                        PIC 9(03)  VALUE 1.
       01 PRINT-SUB-1                  PIC ZZ9.
       01 EOF-FLAG                     PIC X(01)  VALUE 'N'.
          88 EOF-YES                              VALUE 'Y'.
       01 INPUT-FLAG                   PIC X(01)  VALUE 'N'.
          88 INPUT-VALID                          VALUE 'Y'.
       01 EXIT-FLAG                    PIC X(01)  VALUE 'N'.
          88 EXIT-YES                             VALUE 'Y'.
       01 STOCK-FOUND-FLAG             PIC X(01)  VALUE 'N'.
          88  STOCK-FOUND                         VALUE 'Y'.
       01 HYPHEN-LINE                  PIC X(80)  VALUE ALL "-".
       01 DASH-LINE                    PIC X(80)  VALUE ALL "=".
       01 BLANK-LINE                   PIC X(80)  VALUE ALL " ".
       01 RECORD-CTL                   PIC 9(02)  VALUE ZERO.
       01 STOCKS-TABLE.
          05 STOCKS-VALUE OCCURS 20 TIMES.
             10 T-STOCK-SYMBOL         PIC X(07).
             10 T-STOCK-NAME           PIC X(25).
             10 T-CLOSING-PRICE        PIC $$$$$9.99.
             10 T-ANALYST-RECOMM       PIC 9(01).
       01 USER-INPUT                   PIC X(10).
          88 STRONG-BUY                           VALUE "STRONG BUY".
          88 BUY                                  VALUE "BUY".
          88 HOLD                                 VALUE "HOLD".
          88 SELL                                 VALUE "SELL".
          88 QUIT                                 VALUE "QUIT".
          88 VALID-INPUT  VALUE "STRONG BUY" "BUY" "HOLD" "SELL" "QUIT".
       01 USER-INPUT-NUM               PIC 9(01).
       01 RECORDS-READ                 PIC 9(03)  VALUE ZERO.
       01 RECORDS-DISPLAYED            PIC 9(03)  VALUE ZERO.
       01 PRINT-RECORDS-READ           PIC ZZ9.
       01 PRINT-RECORDS-DISPLAYED      PIC ZZ9.
      ******************************************************************
       PROCEDURE DIVISION.
      ******************************************************************
      ******************************************************************
       100-PROCESS-DATA.
      ******************************************************************
           PERFORM 210-INITIALISE-ROUTINE.
           PERFORM 240-DISPLAY-STOCKS UNTIL EXIT-YES.
           PERFORM 290-CLOSE-FILES.
           STOP RUN.
      ******************************************************************
       210-INITIALISE-ROUTINE.
      ******************************************************************
           PERFORM 310-OPEN-FILES.
           PERFORM 320-LOAD-STOCK-RECORDS UNTIL EOF-YES.
           PERFORM 330-PROMPT-USER.
      ******************************************************************
       240-DISPLAY-STOCKS.
      ******************************************************************
           PERFORM  340-SEARCH-STOCK-TABLE
                    VARYING SUB-1 FROM 1 BY 1 UNTIL SUB-1 > 20.

           IF RECORDS-DISPLAYED = 0
              DISPLAY " -> No stock satisfying the recommendation."
           END-IF.

           MOVE RECORDS-READ TO PRINT-RECORDS-READ.
           MOVE RECORDS-DISPLAYED TO PRINT-RECORDS-DISPLAYED.
           DISPLAY HYPHEN-LINE.
           DISPLAY PRINT-RECORDS-READ " STOCKS HAVE BEEN SEARCHED."
           DISPLAY PRINT-RECORDS-DISPLAYED
                   " STOCK RECOMMENDATION(S) FOR " USER-INPUT.

           MOVE SPACE TO USER-INPUT.
           MOVE 0   TO USER-INPUT-NUM RECORDS-DISPLAYED.
           MOVE "N" TO INPUT-FLAG.
           PERFORM 330-PROMPT-USER.
      ******************************************************************
       290-CLOSE-FILES.
      ******************************************************************
           CLOSE STOCKS-FILE.

      ******************************************************************
       310-OPEN-FILES.
      ******************************************************************
           OPEN INPUT STOCKS-FILE.
      ******************************************************************
       320-LOAD-STOCK-RECORDS.
      ******************************************************************
           READ STOCKS-FILE
             AT END
               MOVE RECORDS-READ TO PRINT-RECORDS-READ
               SET EOF-YES TO TRUE
               IF RECORD-CTL = 0
                  DISPLAY "NO DATA IN THE STOCKS FILE. "
               END-IF
               DISPLAY BLANK-LINE
               IF SUB-1 < 20
                  DISPLAY "TABLE IS NOT FULL, " PRINT-RECORDS-READ
                          " STOCKS IN THE TABLE."
               END-IF
             NOT AT END
               IF SUB-1 > 20
                  DISPLAY BLANK-LINE
                  DISPLAY
                  "TABLE IS FULL. STILL VALID RECORDS LEFT IN THE FILE."
                  SET EOF-YES TO TRUE
               ELSE
                  ADD 1 TO RECORD-CTL
                  PERFORM 420-LOAD-STOCKS-TABLE
               END-IF
           END-READ.
      ******************************************************************
       330-PROMPT-USER.
      ******************************************************************
           PERFORM UNTIL INPUT-VALID
             DISPLAY DASH-LINE
             DISPLAY "Enter a stock recommendation, or 'QUIT' to exit:"
             DISPLAY "(Options: 'STRONG BUY', 'BUY', 'HOLD' or 'SELL'.)"
             ACCEPT USER-INPUT
             DISPLAY BLANK-LINE

             IF NOT VALID-INPUT
                DISPLAY "!!INVALID INPUT!!"
             ELSE
                SET INPUT-VALID TO TRUE
             END-IF
           END-PERFORM.

           EVALUATE TRUE
             WHEN STRONG-BUY    MOVE 1 TO USER-INPUT-NUM
             WHEN BUY           MOVE 2 TO USER-INPUT-NUM
             WHEN HOLD          MOVE 3 TO USER-INPUT-NUM
             WHEN SELL          MOVE 4 TO USER-INPUT-NUM
             WHEN QUIT          SET EXIT-YES TO TRUE
                                DISPLAY "PROGRAM TERMINATED."
           END-EVALUATE.
      ******************************************************************
       340-SEARCH-STOCK-TABLE.
      ******************************************************************
           IF T-ANALYST-RECOMM(SUB-1) = USER-INPUT-NUM
              ADD 1 TO RECORDS-DISPLAYED
              MOVE RECORDS-DISPLAYED TO PRINT-RECORDS-DISPLAYED
              DISPLAY PRINT-RECORDS-DISPLAYED
                      ". STOCK NAME: " T-STOCK-NAME(SUB-1)
                     ", CLOSING PRICE: " T-CLOSING-PRICE(SUB-1)
           END-IF.
      ******************************************************************
       420-LOAD-STOCKS-TABLE.
      ******************************************************************
           IF VALID-CODE
               MOVE S-STOCK-SYMBOL   TO T-STOCK-SYMBOL(SUB-1)
               MOVE S-STOCK-NAME     TO T-STOCK-NAME(SUB-1)
               MOVE S-CLOSING-PRICE  TO T-CLOSING-PRICE(SUB-1)
               MOVE S-ANALYST-RECOMM TO T-ANALYST-RECOMM(SUB-1)
               ADD 1 TO RECORDS-READ SUB-1
           ELSE
               DISPLAY "STOCK " S-STOCK-SYMBOL
                      " WITH INVALID RECOMMENDATION CODE - "
                       S-ANALYST-RECOMM " - SKIPPED."
           END-IF.
      ******************************************************************
       END PROGRAM LAB4.
      ******************************************************************

      ******************************************************************
      * Author: CHENG, Annabel
      * StudentID: 041146557
      * Course and Section: CST8283 311
      * Date: 2025-06-05
      * Purpose: PROJECT1 PROCESS EMPLOYEE RECORDS
      *          INSERT AND DISPLAY RECORDS
      * Tectonics: cobc
      ******************************************************************
       IDENTIFICATION DIVISION.
      ******************************************************************
       PROGRAM-ID. Project1_AnnabelCheng.
      ******************************************************************
       ENVIRONMENT DIVISION.
      ******************************************************************
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMP-FILE
             ASSIGN TO "../EMPLOYEES.TXT"
             ORGANIZATION IS LINE SEQUENTIAL.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       FILE SECTION.
       FD EMP-FILE.
       01 EMP-RECORD.
           05 EMPID                    PIC 9(06).
           05 DPTID                    PIC 9(03).
           05 FIRSTNAME                PIC X(20).
           05 LASTNAME                 PIC X(20).
           05 SRVYEARS                 PIC 99.9.

       WORKING-STORAGE SECTION.
       01 EOF-FLAG                     PIC X(01)  VALUE 'N'.
           88 EOF-YES                             VALUE 'Y'.
       01 INPUT-FLAG                   PIC X(01)  .
           88 INPUT-YES                           VALUE 'Y'.
           88 INPUT-NO                            VALUE 'N'.
           88 INPUT-SPACE                         VALUE SPACE.
       01 RECORD-CTL                   PIC 9(1)   VALUE ZERO.

       01 HEADER1                      PIC X(50)  VALUE
            "EMPLOYEE RECORDS".
       01 HEADER2                      PIC X(100).

       01 DASH-LINE PIC X(75) VALUE ALL "=".
       01 BLANK-LINE PIC X(75) VALUE ALL " ".

       01 EMP-RECORD-PRINT.
           05 EMPID-PRINT              PIC X(06).
           05 FILLER                   PIC X(06) VALUE SPACES.
           05 DPTID-PRINT              PIC X(03).
           05 FILLER                   PIC X(02) VALUE SPACES.
           05 FIRSTNAME-PRINT          PIC X(20).
           05 FILLER                   PIC X(01) VALUE SPACE.
           05 LASTNAME-PRINT           PIC X(20).
           05 FILLER                   PIC X(01) VALUE SPACE.
           05 SRVYEARS-PRINT           PIC Z9.9.

      ******************************************************************
       PROCEDURE DIVISION.
      ******************************************************************
       100-PROCESS-EMPLOYEE-RECORDS.
           PERFORM 210-INITIALISE-ROUTINE.
           PERFORM 220-CREATE-EMPLOYEE-RECORD UNTIL INPUT-NO.
           PERFORM 250-CLOSE-FILE.
           PERFORM 240-OPEN-INPUT-FILE.
           PERFORM 230-DISPLAY-RECORDS
           PERFORM 250-CLOSE-FILE.
           STOP RUN.

       210-INITIALISE-ROUTINE.
           PERFORM 310-OPEN-OUTPUT-FILE.
           PERFORM 320-PROMPT-WHETHER-INPUT-RECORD.

       220-CREATE-EMPLOYEE-RECORD.
           PERFORM 330-INPUT-EMPLOYEE-DATA.
           PERFORM 340-WRITE-RECORD-TO-FILE.
           PERFORM 320-PROMPT-WHETHER-INPUT-RECORD.

       230-DISPLAY-RECORDS.
           PERFORM 345-PRINT-HEADERS.
           PERFORM 350-READ-EMPLOYEE-RECORD UNTIL EOF-YES.

       240-OPEN-INPUT-FILE.
           OPEN INPUT EMP-FILE.

       250-CLOSE-FILE.
           CLOSE EMP-FILE.

       310-OPEN-OUTPUT-FILE.
           OPEN OUTPUT EMP-FILE.     *> IT OVERWRITES EVERYTIME.

       320-PROMPT-WHETHER-INPUT-RECORD.
           SET INPUT-SPACE TO TRUE.
           PERFORM UNTIL INPUT-YES OR INPUT-NO
               DISPLAY DASH-LINE
               DISPLAY "Adding a new employee record? (Y/N):"
               ACCEPT  INPUT-FLAG
               DISPLAY BLANK-LINE
               MOVE FUNCTION UPPER-CASE(INPUT-FLAG) TO INPUT-FLAG

               IF NOT INPUT-YES AND NOT INPUT-NO
                  DISPLAY "Invalid input. Please enter 'Y/N' only."
                  DISPLAY DASH-LINE
               END-IF
           END-PERFORM.

       330-INPUT-EMPLOYEE-DATA.
           DISPLAY "ENTER EMPLOYEE ID (6 DIGITS): ".
           ACCEPT EMPID.

           DISPLAY "ENTER DEPARTMENT ID (3 DIGITS): ".
           ACCEPT DPTID.

           DISPLAY "ENTER FIRST NAME (MAX 20 CHAR): ".
           ACCEPT FIRSTNAME.

           DISPLAY "ENTER LAST NAME (MAX 20 CHAR): ".
           ACCEPT LASTNAME.

           DISPLAY "ENTER SERVICE YEARS (FORMAT 99.9): ".
           ACCEPT SRVYEARS.

       340-WRITE-RECORD-TO-FILE.
           WRITE EMP-RECORD.

       345-PRINT-HEADERS.
           STRING
             "EMPLOYEE ID DEPT FIRST NAME" DELIMITED BY SIZE
             INTO HEADER2 (1:38)
           END-STRING.

           STRING
             "LAST NAME            SERVICE YEAR" DELIMITED BY SIZE
             INTO HEADER2 (39:)
           END-STRING.

           DISPLAY HEADER1.
           DISPLAY DASH-LINE.
           DISPLAY HEADER2.
           DISPLAY DASH-LINE.

       350-READ-EMPLOYEE-RECORD.
           READ EMP-FILE
             AT END
               SET EOF-YES TO TRUE
               IF RECORD-CTL = 0
                  DISPLAY "NO RECORD IN THE FILE. "
               END-IF
               DISPLAY DASH-LINE
             NOT AT END
               MOVE 1 TO RECORD-CTL
               PERFORM 360-DISPLAY-EMPLOYEE-RECORD
           END-READ.

       360-DISPLAY-EMPLOYEE-RECORD.

           MOVE EMPID TO EMPID-PRINT.
           MOVE DPTID TO DPTID-PRINT.
           MOVE FIRSTNAME TO FIRSTNAME-PRINT.
           MOVE LASTNAME TO LASTNAME-PRINT.
           MOVE SRVYEARS TO SRVYEARS-PRINT.

           DISPLAY EMP-RECORD-PRINT.

       END PROGRAM Project1_AnnabelCheng.

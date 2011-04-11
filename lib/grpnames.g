#############################################################################
##
#W  grpnames.g                                                    Stefan Kohl
##
#H  @(#)$Id$
##
#Y  Copyright (C) 2004 The GAP Group
##
##  This file contains a list of precomputed structure descriptions of small
##  groups.
##
##  NAMES_OF_SMALL_GROUPS[n][i] is the description corresponding to
##  SmallGroup(n,i).
##
Revision.grpnames_g :=
  "@(#)$Id$";

NAMES_OF_SMALL_GROUPS :=
[ [ "1" ], [ "C2" ], [ "C3" ], [ "C4", "C2 x C2" ], [ "C5" ], [ "S3", "C6" ],
  [ "C7" ], [ "C8", "C4 x C2", "D8", "Q8", "C2 x C2 x C2" ],
  [ "C9", "C3 x C3" ], [ "D10", "C10" ], [ "C11" ],
  [ "C3 : C4", "C12", "A4", "D12", "C6 x C2" ], [ "C13" ], [ "D14", "C14" ],
  [ "C15" ],
  [ "C16", "C4 x C4", "(C4 x C2) : C2", "C4 : C4", "C8 x C2", "C8 : C2",
      "D16", "QD16", "Q16", "C4 x C2 x C2", "C2 x D8", "C2 x Q8",
      "(C4 x C2) : C2", "C2 x C2 x C2 x C2" ], [ "C17" ],
  [ "D18", "C18", "C3 x S3", "(C3 x C3) : C2", "C6 x C3" ], [ "C19" ],
  [ "C5 : C4", "C20", "C5 : C4", "D20", "C10 x C2" ], [ "C7 : C3", "C21" ],
  [ "D22", "C22" ], [ "C23" ],
  [ "C3 : C8", "C24", "SL(2,3)", "C3 : Q8", "C4 x S3", "D24",
      "C2 x (C3 : C4)", "(C6 x C2) : C2", "C12 x C2", "C3 x D8", "C3 x Q8",
      "S4", "C2 x A4", "C2 x C2 x S3", "C6 x C2 x C2" ], [ "C25", "C5 x C5" ],
  [ "D26", "C26" ],
  [ "C27", "C9 x C3", "(C3 x C3) : C3", "C9 : C3", "C3 x C3 x C3" ],
  [ "C7 : C4", "C28", "D28", "C14 x C2" ], [ "C29" ],
  [ "C5 x S3", "C3 x D10", "D30", "C30" ], [ "C31" ],
  [ "C32", "(C4 x C2) : C4", "C8 x C4", "C8 : C4", "(C8 x C2) : C2",
      "((C4 x C2) : C2) : C2", "(C8 : C2) : C2",
      "C2 . ((C4 x C2) : C2) = (C2 x C2) . (C4 x C2)", "(C8 x C2) : C2",
      "Q8 : C4", "(C4 x C4) : C2", "C4 : C8", "C8 : C4", "C8 : C4",
      "C4 . D8 = C4 . (C4 x C2)", "C16 x C2", "C16 : C2", "D32", "QD32",
      "Q32", "C4 x C4 x C2", "C2 x ((C4 x C2) : C2)", "C2 x (C4 : C4)",
      "(C4 x C4) : C2", "C4 x D8", "C4 x Q8", "(C2 x C2 x C2 x C2) : C2",
      "(C4 x C2 x C2) : C2", "(C2 x Q8) : C2", "(C4 x C2 x C2) : C2",
      "(C4 x C4) : C2", "(C2 x C2) . (C2 x C2 x C2)", "(C4 x C4) : C2",
      "(C4 x C4) : C2", "C4 : Q8", "C8 x C2 x C2", "C2 x (C8 : C2)",
      "(C8 x C2) : C2", "C2 x D16", "C2 x QD16", "C2 x Q16", "(C8 x C2) : C2",
      "(C2 x D8) : C2", "(C2 x Q8) : C2", "C4 x C2 x C2 x C2",
      "C2 x C2 x D8", "C2 x C2 x Q8", "C2 x ((C4 x C2) : C2)",
      "(C2 x D8) : C2", "(C2 x Q8) : C2", "C2 x C2 x C2 x C2 x C2" ],
  [ "C33" ], [ "D34", "C34" ], [ "C35" ],
  [ "C9 : C4", "C36", "(C2 x C2) : C9", "D36", "C18 x C2", "C3 x (C3 : C4)",
      "(C3 x C3) : C4", "C12 x C3", "(C3 x C3) : C4", "S3 x S3", "C3 x A4",
      "C6 x S3", "C2 x ((C3 x C3) : C2)", "C6 x C6" ], [ "C37" ],
  [ "D38", "C38" ], [ "C13 : C3", "C39" ],
  [ "C5 : C8", "C40", "C5 : C8", "C5 : Q8", "C4 x D10", "D40",
      "C2 x (C5 : C4)", "(C10 x C2) : C2", "C20 x C2", "C5 x D8", "C5 x Q8",
      "C2 x (C5 : C4)", "C2 x C2 x D10", "C10 x C2 x C2" ], [ "C41" ],
  [ "(C7 : C3) : C2", "C2 x (C7 : C3)", "C7 x S3", "C3 x D14", "D42", "C42" ],
  [ "C43" ], [ "C11 : C4", "C44", "D44", "C22 x C2" ], [ "C45", "C15 x C3" ],
  [ "D46", "C46" ], [ "C47" ],
  [ "C3 : C16", "C48", "(C4 x C4) : C3", "C8 x S3", "C24 : C2", "C24 : C2",
      "D48", "C3 : Q16", "C2 x (C3 : C8)", "(C3 : C8) : C2", "C4 x (C3 : C4)",
      "(C3 : C4) : C4", "C12 : C4", "(C12 x C2) : C2", "(C3 x D8) : C2",
      "(C3 : C8) : C2", "(C3 x Q8) : C2", "C3 : Q16", "(C2 x (C3 : C4)) : C2",
      "C12 x C4", "C3 x ((C4 x C2) : C2)", "C3 x (C4 : C4)", "C24 x C2",
      "C3 x (C8 : C2)", "C3 x D16", "C3 x QD16", "C3 x Q16",
      "C2 . S4 = SL(2,3) . C2", "GL(2,3)", "A4 : C4", "C4 x A4",
      "C2 x SL(2,3)", "SL(2,3) : C2", "C2 x (C3 : Q8)", "C2 x C4 x S3",
      "C2 x D24", "(C12 x C2) : C2", "D8 x S3", "(C2 x (C3 : C4)) : C2",
      "Q8 x S3", "(C4 x S3) : C2", "C2 x C2 x (C3 : C4)",
      "C2 x ((C6 x C2) : C2)", "C12 x C2 x C2", "C6 x D8", "C6 x Q8",
      "C3 x ((C4 x C2) : C2)", "C2 x S4", "C2 x C2 x A4",
      "(C2 x C2 x C2 x C2) : C3", "C2 x C2 x C2 x S3", "C6 x C2 x C2 x C2" ],
  [ "C49", "C7 x C7" ],
  [ "D50", "C50", "C5 x D10", "(C5 x C5) : C2", "C10 x C5" ], [ "C51" ],
  [ "C13 : C4", "C52", "C13 : C4", "D52", "C26 x C2" ], [ "C53" ],
  [ "D54", "C54", "C3 x D18", "C9 x S3", "((C3 x C3) : C3) : C2",
      "(C9 : C3) : C2", "(C9 x C3) : C2", "((C3 x C3) : C3) : C2",
      "C18 x C3", "C2 x ((C3 x C3) : C3)", "C2 x (C9 : C3)", "C3 x C3 x S3",
      "C3 x ((C3 x C3) : C2)", "(C3 x C3 x C3) : C2", "C6 x C3 x C3" ],
  [ "C11 : C5", "C55" ],
  [ "C7 : C8", "C56", "C7 : Q8", "C4 x D14", "D56", "C2 x (C7 : C4)",
      "(C14 x C2) : C2", "C28 x C2", "C7 x D8", "C7 x Q8",
      "(C2 x C2 x C2) : C7", "C2 x C2 x D14", "C14 x C2 x C2" ],
  [ "C19 : C3", "C57" ], [ "D58", "C58" ], [ "C59" ],
  [ "C5 x (C3 : C4)", "C3 x (C5 : C4)", "C15 : C4", "C60", "A5",
      "C3 x (C5 : C4)", "C15 : C4", "S3 x D10", "C5 x A4", "C6 x D10",
      "C10 x S3", "D60", "C30 x C2" ], [ "C61" ], [ "D62", "C62" ],
  [ "C7 : C9", "C63", "C3 x (C7 : C3)", "C21 x C3" ],, [ "C65" ],
  [ "C11 x S3", "C3 x D22", "D66", "C66" ], [ "C67" ],
  [ "C17 : C4", "C68", "C17 : C4", "D68", "C34 x C2" ], [ "C69" ],
  [ "C7 x D10", "C5 x D14", "D70", "C70" ], [ "C71" ],
  [ "C9 : C8", "C72", "Q8 : C9", "C9 : Q8", "C4 x D18", "D72",
      "C2 x (C9 : C4)", "(C18 x C2) : C2", "C36 x C2", "C9 x D8", "C9 x Q8",
      "C3 x (C3 : C8)", "(C3 x C3) : C8", "C24 x C3", "((C2 x C2) : C9) : C2",
      "C2 x ((C2 x C2) : C9)", "C2 x C2 x D18", "C18 x C2 x C2",
      "(C3 x C3) : C8", "(C3 : C4) x S3", "(C3 x (C3 : C4)) : C2",
      "(C6 x S3) : C2", "(C6 x S3) : C2", "(C3 x C3) : Q8", "C3 x SL(2,3)",
      "C3 x (C3 : Q8)", "C12 x S3", "C3 x D24", "C6 x (C3 : C4)",
      "C3 x ((C6 x C2) : C2)", "(C3 x C3) : Q8", "C4 x ((C3 x C3) : C2)",
      "(C12 x C3) : C2", "C2 x ((C3 x C3) : C4)", "(C6 x C6) : C2",
      "C12 x C6", "C3 x C3 x D8", "C3 x C3 x Q8", "(C3 x C3) : C8",
      "(S3 x S3) : C2", "(C3 x C3) : Q8", "C3 x S4", "(C3 x A4) : C2",
      "A4 x S3", "C2 x ((C3 x C3) : C4)", "C2 x S3 x S3", "C6 x A4",
      "C2 x C6 x S3", "C2 x C2 x ((C3 x C3) : C2)", "C6 x C6 x C2" ],
  [ "C73" ], [ "D74", "C74" ], [ "C75", "(C5 x C5) : C3", "C15 x C5" ],
  [ "C19 : C4", "C76", "D76", "C38 x C2" ], [ "C77" ],
  [ "(C13 : C3) : C2", "C2 x (C13 : C3)", "C13 x S3", "C3 x D26", "D78",
      "C78" ], [ "C79" ],
  [ "C5 : C16", "C80", "C5 : C16", "C8 x D10", "C40 : C2", "C40 : C2", "D80",
      "C5 : Q16", "C2 x (C5 : C8)", "(C5 : C8) : C2", "C4 x (C5 : C4)",
      "(C5 : C4) : C4", "C20 : C4", "(C20 x C2) : C2", "(C5 x D8) : C2",
      "(C5 : C8) : C2", "(C5 x Q8) : C2", "C5 : Q16", "(C2 x (C5 : C4)) : C2",
      "C20 x C4", "C5 x ((C4 x C2) : C2)", "C5 x (C4 : C4)", "C40 x C2",
      "C5 x (C8 : C2)", "C5 x D16", "C5 x QD16", "C5 x Q16", "(C5 : C8) : C2",
      "(C5 : C8) : C2", "C4 x (C5 : C4)", "C20 : C4", "C2 x (C5 : C8)",
      "(C5 : C8) : C2", "(C2 x (C5 : C4)) : C2", "C2 x (C5 : Q8)",
      "C2 x C4 x D10", "C2 x D40", "(C20 x C2) : C2", "D8 x D10",
      "(C2 x (C5 : C4)) : C2", "Q8 x D10", "(C4 x D10) : C2",
      "C2 x C2 x (C5 : C4)", "C2 x ((C10 x C2) : C2)", "C20 x C2 x C2",
      "C10 x D8", "C10 x Q8", "C5 x ((C4 x C2) : C2)",
      "(C2 x C2 x C2 x C2) : C5", "C2 x C2 x (C5 : C4)", "C2 x C2 x C2 x D10",
      "C10 x C2 x C2 x C2" ],
  [ "C81", "C9 x C9", "(C9 x C3) : C3", "C9 : C9", "C27 x C3", "C27 : C3",
      "(C3 x C3 x C3) : C3", "(C9 x C3) : C3", "(C9 x C3) : C3",
      "C3 . ((C3 x C3) : C3) = (C3 x C3) . (C3 x C3)", "C9 x C3 x C3",
      "C3 x ((C3 x C3) : C3)", "C3 x (C9 : C3)", "(C9 x C3) : C3",
      "C3 x C3 x C3 x C3" ], [ "D82", "C82" ], [ "C83" ],
  [ "(C7 : C4) : C3", "C4 x (C7 : C3)", "C7 x (C3 : C4)", "C3 x (C7 : C4)",
      "C21 : C4", "C84", "C2 x ((C7 : C3) : C2)", "S3 x D14",
      "C2 x C2 x (C7 : C3)", "C7 x A4", "(C14 x C2) : C3", "C6 x D14",
      "C14 x S3", "D84", "C42 x C2" ], [ "C85" ], [ "D86", "C86" ],
  [ "C87" ],
  [ "C11 : C8", "C88", "C11 : Q8", "C4 x D22", "D88", "C2 x (C11 : C4)",
      "(C22 x C2) : C2", "C44 x C2", "C11 x D8", "C11 x Q8", "C2 x C2 x D22",
      "C22 x C2 x C2" ], [ "C89" ],
  [ "C5 x D18", "C9 x D10", "D90", "C90", "C3 x C3 x D10", "C15 x S3",
      "C3 x D30", "C5 x ((C3 x C3) : C2)", "(C15 x C3) : C2", "C30 x C3" ],
  [ "C91" ], [ "C23 : C4", "C92", "D92", "C46 x C2" ], [ "C31 : C3", "C93" ],
  [ "D94", "C94" ], [ "C95" ],, [ "C97" ],
  [ "D98", "C98", "C7 x D14", "(C7 x C7) : C2", "C14 x C7" ],
  [ "C99", "C33 x C3" ],
  [ "C25 : C4", "C100", "C25 : C4", "D100", "C50 x C2", "C5 x (C5 : C4)",
      "(C5 x C5) : C4", "C20 x C5", "C5 x (C5 : C4)", "(C5 x C5) : C4",
      "(C5 x C5) : C4", "(C5 x C5) : C4", "D10 x D10", "C10 x D10",
      "C2 x ((C5 x C5) : C2)", "C10 x C10" ] ];
MakeReadOnlyGlobal( "NAMES_OF_SMALL_GROUPS" );

#############################################################################
##
#E  grpnames.g . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here
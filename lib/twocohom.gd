#############################################################################
##
#W  twocohom.gd                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
Revision.twocohom_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  CollectedWordSQ( <C>, <u>, <v> ) 
##
##  <ManSection>
##  <Func Name="CollectedWordSQ" Arg='C, u, v'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CollectedWordSQ" );

#############################################################################
##
#F  CollectorSQ( <G>, <M>, <isSplit> )
##
##  <ManSection>
##  <Func Name="CollectorSQ" Arg='G, M, isSplit'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CollectorSQ" );

#############################################################################
##
#F  AddEquationsSQ( <eq>, <t1>, <t2> )
##
##  <ManSection>
##  <Func Name="AddEquationsSQ" Arg='eq, t1, t2'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AddEquationsSQ" );

#############################################################################
##
#F  SolutionSQ( <C>, <eq> )
##
##  <ManSection>
##  <Func Name="SolutionSQ" Arg='C, eq'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SolutionSQ" );

#############################################################################
##
#F  TwoCocyclesSQ( <C>, <G>, <M> )
##
##  <ManSection>
##  <Func Name="TwoCocyclesSQ" Arg='C, G, M'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "TwoCocyclesSQ" );

#############################################################################
##
#F  TwoCoboundariesSQ( <C>, <G>, <M> )
##
##  <ManSection>
##  <Func Name="TwoCoboundariesSQ" Arg='C, G, M'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "TwoCoboundariesSQ" );

#############################################################################
##
#F  TwoCohomologySQ( <C>, <G>, <M> )
##
##  <ManSection>
##  <Func Name="TwoCohomologySQ" Arg='C, G, M'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "TwoCohomologySQ" );


#############################################################################
##
#O  TwoCocycles( <G>, <M> )
##
##  <#GAPDoc Label="TwoCocycles">
##  <ManSection>
##  <Oper Name="TwoCocycles" Arg='G, M'/>
##
##  <Description>
##  returns the <M>2</M>-cocycles of a pc group <A>G</A> by the
##  <A>G</A>-module <A>M</A>. 
##  The generators of <A>M</A> must correspond to the <Ref Func="Pcgs"/>
##  value of <A>G</A>. The operation
##  returns a list of vectors over the field underlying <A>M</A> and the 
##  additive group generated by these vectors is the group of
##  <M>2</M>-cocyles.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TwoCocycles", [ IsPcGroup, IsObject ] );


#############################################################################
##
#O  TwoCoboundaries( <G>, <M> )
##
##  <#GAPDoc Label="TwoCoboundaries">
##  <ManSection>
##  <Oper Name="TwoCoboundaries" Arg='G, M'/>
##
##  <Description>
##  returns the group of <M>2</M>-coboundaries of a pc group <A>G</A> by the
##  <A>G</A>-module <A>M</A>.
##  The generators of <A>M</A> must correspond to the <Ref Func="Pcgs"/>
##  value of <A>G</A>.
##  The group of coboundaries is given as vector space over the field
##  underlying <A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TwoCoboundaries", [ IsPcGroup, IsObject ] );


#############################################################################
##
#O  TwoCohomology( <G>, <M> )
##
##  <#GAPDoc Label="TwoCohomology">
##  <ManSection>
##  <Oper Name="TwoCohomology" Arg='G, M'/>
##
##  <Description>
##  returns a record defining the second cohomology group as factor space of 
##  the space of cocycles by the space of coboundaries.
##  <A>G</A> must be a pc group and the generators of <A>M</A> must
##  correspond to the pcgs of <A>G</A>.
##  <Example><![CDATA[
##  gap> G := SmallGroup( 4, 2 );
##  <pc group of size 4 with 2 generators>
##  gap> mats := List( Pcgs( G ), x -> IdentityMat( 1, GF(2) ) );
##  [ <a 1x1 matrix over GF2>, <a 1x1 matrix over GF2> ]
##  gap> M := GModuleByMats( mats, GF(2) );
##  rec( dimension := 1, field := GF(2), 
##    generators := [ <an immutable 1x1 matrix over GF2>, 
##        <an immutable 1x1 matrix over GF2> ], isMTXModule := true )
##  gap> TwoCoboundaries( G, M );
##  [  ]
##  gap> TwoCocycles( G, M );
##  [ [ Z(2)^0, 0*Z(2), 0*Z(2) ], [ 0*Z(2), Z(2)^0, 0*Z(2) ], 
##    [ 0*Z(2), 0*Z(2), Z(2)^0 ] ]
##  gap> cc := TwoCohomology( G, M );;
##  gap> cc.cohom;
##  <linear mapping by matrix, <vector space of dimension 3 over GF(2)> -> ( GF(
##  2)^3 )>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TwoCohomology", [ IsPcGroup, IsObject ] );


#############################################################################
##
#E


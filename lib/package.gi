#############################################################################
##
#W  package.gi                  GAP Library                      Frank Celler
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains support for &GAP; packages.
##
Revision.package_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  CompareVersionNumbers( <supplied>, <required>[, "equal"] )
##
InstallGlobalFunction( CompareVersionNumbers, function( arg )
    local s, r, inequal, i, j, a, b;

    s:= arg[1];
    r:= arg[2];
    inequal:= not ( Length( arg ) = 3 and arg[3] = "equal" );

    # Deal with the case of a `dev' version.
    if   2 < Length( s )
       and s{ [ Length( s ) - 2 .. Length( s ) ] } = "dev" then
      return inequal or ( Length(r)>2 and r{[Length(r)-2..Length(r)]}="dev" );
    elif 2 < Length( r )
       and r{ [ Length( r ) - 2 .. Length( r ) ] } = "dev" then
      return false;
    fi;

    while 0 < Length( s ) or 0 < Length( r ) do

      # Remove leading non-digit characters.
      i:= 1;
      while i <= Length( s ) and not IsDigitChar( s[i] ) do
        i:= i+1;
      od;
      s:= s{ [ i .. Length( s ) ] };
      j:= 1;
      while j <= Length( r ) and not IsDigitChar( r[j] ) do
        j:= j+1;
      od;
      r:= r{ [ j .. Length( r ) ] };

      # If one of the two strings is empty then we are done.
      if   Length( s ) = 0 then
        return Length( r ) = 0;
      elif Length( r ) = 0 then
        return inequal;
      fi;

      # Compare the next portion of digit characters.
      i:= 1;
      while i <= Length( s ) and IsDigitChar( s[i] ) do
        i:= i+1;
      od;
      a:= Int( s{ [ 1 .. i-1 ] } );
      j:= 1;
      while j <= Length( r ) and IsDigitChar( r[j] ) do
        j:= j+1;
      od;
      b:= Int( r{ [ 1 .. j-1 ] } );
      if   a < b then
        return false;
      elif b < a then
        return inequal;
      fi;
      s:= s{ [ i .. Length( s ) ] };
      r:= r{ [ j .. Length( r ) ] };

    od;

    # The two remaining strings are empty.
    return true;
end );


#############################################################################
##
#F  PackageInfo( <pkgname> )
##
InstallGlobalFunction( PackageInfo, function( pkgname )
    pkgname:= LowercaseString( pkgname );
    if not IsBound( GAPInfo.PackagesInfo.( pkgname ) ) then
      return [];
    else
      return GAPInfo.PackagesInfo.( pkgname );
    fi;
    end );


#############################################################################
##
#F  RECORDS_FILE( <name> )
##
InstallGlobalFunction( RECORDS_FILE, function( name )
    local str, rows, recs, pos, r;

    str:= StringFile( name );
    if str = fail then
      return [];
    fi;
    rows:= SplitString( str, "", "\n" );
    recs:= [];
    for r in rows do
      # remove comments starting with `#'
      pos:= Position( r, '#' );
      if pos <> fail then
        r:= r{ [ 1 .. pos-1 ] };
      fi;
      Append( recs, SplitString( r, "", " \n\t\r" ) );
    od;
    return List( recs, LowercaseString );
    end );


#############################################################################
##
#F  SetPackageInfo( <record> )
##
InstallGlobalFunction( SetPackageInfo, function( record )
    GAPInfo.PackageInfoCurrent:= record;
    end );


#############################################################################
##
#F  InitializePackagesInfoRecords()
##
##  In earlier versions, this function had an argument; now we ignore it.
##
InstallGlobalFunction( InitializePackagesInfoRecords, function( arg )
    local dirs, pkgdirs, pkgdir, names, noauto, name, pkgpath,
          file, files, subdir, str, record, r, pkgname, version;

    if IsBound( GAPInfo.PackagesInfoInitialized ) and
       GAPInfo.PackagesInfoInitialized = true then
      # This function has already been executed in this sesion.
      return;
    fi;

    GAPInfo.PackagesInfo:= [];
    GAPInfo.PackagesInfoRefuseLoad:= [];

    LogPackageLoadingMessage( PACKAGE_DEBUG,
        "enter InitializePackagesInfoRecords", "GAP" );
    dirs:= [];
    pkgdirs:= DirectoriesLibrary( "pkg" );
    if pkgdirs = fail then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "exit InitializePackagesInfoRecords (no pkg directories found)",
          "GAP" );
      GAPInfo.PackagesInfo:= rec();
      return;
    fi;

    # Loop over the package directories,
    # remove the packages listed in `NOAUTO' files from GAP's suggested
    # packages, and unite the information for the directories.
    for pkgdir in pkgdirs do

      noauto:= RECORDS_FILE( Filename( pkgdir, "NOAUTO" ) );
      if not IsEmpty( noauto ) then
        GAPInfo.Dependencies.SuggestedOtherPackages:= Filtered(
            GAPInfo.Dependencies.SuggestedOtherPackages,
            x -> not x in noauto );
      fi;

      # Loop over subdirectories of this package directory.
      for name in Set( DirectoryContents( Filename( pkgdir, "" ) ) ) do
        pkgpath:= Filename( [ pkgdir ], name );
        # This can be 'fail' if 'name' is a void link.
        if pkgpath <> fail and IsDirectoryPath( pkgpath )
                           and not name in [ ".", ".." ] then
          file:= Filename( [ pkgdir ],
                           Concatenation( name, "/PackageInfo.g" ) );
          if file = fail then
            # Perhaps some subdirectories contain `PackageInfo.g' files.
            files:= [];
            for subdir in Set( DirectoryContents( pkgpath ) ) do
              if not subdir in [ ".", ".." ] then
                pkgpath:= Filename( [ pkgdir ],
                                    Concatenation( name, "/", subdir ) );
                if pkgpath <> fail and IsDirectoryPath( pkgpath )
                                   and not subdir in [ ".", ".." ] then
                  file:= Filename( [ pkgdir ],
                      Concatenation( name, "/", subdir, "/PackageInfo.g" ) );
                  if file <> fail then
                    Add( files,
                         [ file, Concatenation( name, "/", subdir ) ] );
                  fi;
                fi;
              fi;
            od;
          else
            files:= [ [ file, name ] ];
          fi;

          for file in files do

            # Read the `PackageInfo.g' file.
            Unbind( GAPInfo.PackageInfoCurrent );
            Read( file[1] );
            if IsBound( GAPInfo.PackageInfoCurrent ) then
              record:= GAPInfo.PackageInfoCurrent;
              Unbind( GAPInfo.PackageInfoCurrent );
              pkgname:= LowercaseString( record.PackageName );
              NormalizeWhitespace( pkgname );
              version:= record.Version;

              # If we have this version already then leave it out.
              if ForAll( GAPInfo.PackagesInfo,
                         r ->    r.PackageName <> record.PackageName
                              or r.Version <> version ) then

                # Check whether GAP wants to reset loadability.
                if     IsBound( GAPInfo.PackagesRestrictions.( pkgname ) )
                   and GAPInfo.PackagesRestrictions.( pkgname ).OnInitialization(
                           record ) = false then
                  Add( GAPInfo.PackagesInfoRefuseLoad, record );
                else
                  record.InstallationPath:= Filename( [ pkgdir ], file[2] );
                  if not IsBound( record.PackageDoc ) then
                    record.PackageDoc:= [];
                  elif IsRecord( record.PackageDoc ) then
                    record.PackageDoc:= [ record.PackageDoc ];
                  fi;
                  Add( GAPInfo.PackagesInfo, record );
                fi;
              fi;
            fi;
          od;
        fi;
      od;
    od;

    # Sort the available info records by their version numbers.
    SortParallel( List( GAPInfo.PackagesInfo, r -> r.Version ),
                  GAPInfo.PackagesInfo,
                  CompareVersionNumbers );

    # Turn the lists into records.
    record:= rec();
    for r in GAPInfo.PackagesInfo do
      name:= LowercaseString( r.PackageName );
      if IsBound( record.( name ) ) then
        Add( record.( name ), r );
      else
        record.( name ):= [ r ];
      fi;
    od;
    GAPInfo.PackagesInfo:= record;

    GAPInfo.PackagesInfoInitialized:= true;
    LogPackageLoadingMessage( PACKAGE_DEBUG,
        "exit InitializePackagesInfoRecords", "GAP" );
    end );


#############################################################################
##
#F  LinearOrderByPartialWeakOrder( <pairs>, <weights> )
##
##  The algorithm works with a directed graph
##  whose vertices are subsets of the <M>c_i</M>
##  and whose edges represent the given partial order.
##  We start with one vertex for each <M>x_i</M> and each <M>y_i</M>
##  from the input list, and draw an edge from <M>x_i</M> to <M>y_i</M>.
##  Furthermore,
##  we need a queue <M>Q</M> of the smallest vertices found up to now,
##  and a stack <M>S</M> of the largest vertices found up to now;
##  both <M>Q</M> and <M>S</M> are empty at the beginning.
##  Now we add the vertices without predecessors to <M>Q</M> and remove the
##  edges from these vertices until no more such vertex is found.
##  Then we put the vertices without successors on <M>S</M> and remove the
##  edges to these vertices until no more such vertex is found.
##  If edges are left then each of them leads eventually into a cycle in the
##  graph; we find a cycle and amalgamate it into a new vertex.
##  Now we repeat the process until all edges have disappeared.
##  Finally, the concatenation of <M>Q</M> and <M>S</M> gives us the sets
##  <M>c_i</M>.
##
InstallGlobalFunction( LinearOrderByPartialWeakOrder,
    function( pairs, weights )
    local Q, S, Qw, Sw, F, pair, vx, vy, v, pos, candidates, minwght,
          smallest, s, maxwght, largest, p, cycle, next, new;

    # Initialize the queue and the stack.
    Q:= [];
    S:= [];
    Qw:= [];
    Sw:= [];

    # Create a list of vertices according to the input.
    F:= [];
    for pair in Set( pairs ) do
      if pair[1] <> pair[2] then
        vx:= First( F, r -> r.keys[1] = pair[1] );
        if vx = fail then
          vx:= rec( keys:= [ pair[1] ], succ:= [], pred:= [] );
          Add( F, vx );
        fi;
        vy:= First( F, r -> r.keys[1] = pair[2] );
        if vy = fail then
          vy:= rec( keys:= [ pair[2] ], succ:= [], pred:= [] );
          Add( F, vy );
        fi;
        Add( vx.succ, vy );
        Add( vy.pred, vx );
      fi;
    od;

    # Assign the weights.
    weights:= SortedList( weights );
    for v in F do
      pos:= PositionSorted( weights, v.keys );
      if pos <= Length( weights ) and weights[ pos ][1] = v.keys[1] then
        v.wght:= weights[ pos ][2];
      else
        v.wght:= 0;
      fi;
    od;

    # While F contains a vertex, ...
    while not IsEmpty( F ) do

      # ... find the vertices in F without predecessors and add them to Q,
      # remove the edges from these vertices,
      # and remove these vertices from F.
      candidates:= Filtered( F, v -> IsEmpty( v.pred ) );
      if not IsEmpty( candidates ) then
        minwght:= infinity;    # larger than all admissible weights
        for v in candidates do
          if v.wght < minwght then
            minwght:= v.wght;
            smallest:= [ v ];
          elif v.wght = minwght then
            Add( smallest, v );
          fi;
        od;
        for v in smallest do
          Add( Q, v.keys );
          Add( Qw, v.wght );
          for s in v.succ do
            s.pred:= Filtered( s.pred, x -> not IsIdenticalObj( v, x ) );
            if IsEmpty( s.pred )
               and ForAll( smallest, x -> not IsIdenticalObj( s, x ) ) then
              Add( smallest, s );
            fi;
          od;
          pos:= PositionProperty( F, x -> IsIdenticalObj( v, x ) );
          Unbind( F[ pos ] );
          F:= Compacted( F );
        od;
      fi;

      # Then find the vertices in F without successors and put them on S,
      # remove the edges to these vertices,
      # and remove these vertices from F.
      candidates:= Filtered( F, v -> IsEmpty( v.succ ) );
      if not IsEmpty( candidates ) then
        maxwght:= -1;    # smaller than all admissible weights
        for v in candidates do
          if v.wght > maxwght then
            maxwght:= v.wght;
            largest:= [ v ];
          elif v.wght = maxwght then
            Add( largest, v );
          fi;
        od;
        for v in largest do
          Add( S, v.keys );
          Add( Sw, v.wght );
          for p in v.pred do
            p.succ:= Filtered( p.succ, x -> not IsIdenticalObj( v, x ) );
            if IsEmpty( p.succ )
               and ForAll( largest, x -> not IsIdenticalObj( p, x ) ) then
              Add( largest, p );
            fi;
          od;
          pos:= PositionProperty( F, x -> IsIdenticalObj( v, x ) );
          Unbind( F[ pos ] );
          F:= Compacted( F );
        od;
      fi;

      if not IsEmpty( F ) then
        # Find a cycle in F.
        # (Note that now any vertex has a successor,
        # so we may start anywhere, and eventually get into a cycle.)
        cycle:= [];
        next:= F[1];
        repeat
          Add( cycle, next );
          next:= next.succ[1];
          pos:= PositionProperty( cycle, x -> IsIdenticalObj( x, next ) );
        until pos <> fail;
        cycle:= cycle{ [ pos .. Length( cycle ) ] };

        # Replace the set of vertices in the cycle by a new vertex,
        # replace all edges from/to a vertex outside the cycle
        # to/from a vertex in the cycle by edges to/from the new vertex.
        new:= rec( keys:= [], succ:= [], pred:= [],
                   wght:= Maximum( List( cycle, v -> v.wght ) ) );
        for v in cycle do
          UniteSet( new.keys, v.keys );
          for s in v.succ do
            if ForAll( cycle, w -> not IsIdenticalObj( s, w ) ) then
              if ForAll( new.succ, w -> not IsIdenticalObj( s, w ) ) then
                Add( new.succ, s );
              fi;
              pos:= PositionProperty( s.pred, w -> IsIdenticalObj( v, w ) );
              if ForAll( s.pred, w -> not IsIdenticalObj( new, w ) ) then
                s.pred[ pos ]:= new;
              else
                Unbind( s.pred[ pos ] );
                s.pred:= Compacted( s.pred );
              fi;
            fi;
          od;
          for p in v.pred do
            if ForAll( cycle, w -> not IsIdenticalObj( p, w ) ) then
              if ForAll( new.pred, w -> not IsIdenticalObj( p, w ) ) then
                Add( new.pred, p );
              fi;
              pos:= PositionProperty( p.succ, w -> IsIdenticalObj( v, w ) );
              if ForAll( p.succ, w -> not IsIdenticalObj( new, w ) ) then
                p.succ[ pos ]:= new;
              else
                Unbind( p.succ[ pos ] );
                p.succ:= Compacted( p.succ );
              fi;
            fi;
          od;
          pos:= PositionProperty( F, x -> IsIdenticalObj( v, x ) );
          Unbind( F[ pos ] );
          F:= Compacted( F );
        od;
        Add( F, new );
      fi;

    od;

    # Now the whole input is distributed to Q and S.
    return rec( cycles:= Concatenation( Q, Reversed( S ) ),
                weights:= Concatenation( Qw, Reversed( Sw ) ) );
    end );


#############################################################################
##
#I  InfoPackageLoading
##
##  (We cannot do this in `package.gd'.)
##
DeclareInfoClass( "InfoPackageLoading" );


#############################################################################
##
#F  LogPackageLoadingMessage( <severity>, <message>[, <name>] )
##
if not IsBound( TextAttr ) then
  TextAttr:= "dummy";
fi;
#T needed? (decl. of GAPDoc is loaded before)

InstallGlobalFunction( LogPackageLoadingMessage, function( arg )
    local severity, message, currpkg, i;

    severity:= arg[1];
    message:= arg[2];
    if Length( arg ) = 3 then
      currpkg:= arg[3];
    elif IsBound( GAPInfo.PackageCurrent ) then
      # This happens inside availability tests.
      currpkg:= GAPInfo.PackageCurrent.PackageName;
    else
      currpkg:= "(unknown package)";
    fi;
    if IsString( message ) then
      message:= [ message ];
    fi;
    if severity <= PACKAGE_WARNING and IsBound( ANSI_COLORS )
       and ANSI_COLORS = true and IsBound( TextAttr )
       and IsRecord( TextAttr ) then
      if severity = PACKAGE_ERROR then
        message:= List( message,
            msg -> Concatenation( TextAttr.1, msg, TextAttr.reset ) );
      else
        message:= List( message,
            msg -> Concatenation( TextAttr.4, msg, TextAttr.reset ) );
      fi;
    fi;
    Add( GAPInfo.PackageLoadingMessages, [ currpkg, severity, message ] );
    Info( InfoPackageLoading, severity, currpkg, ": ", message[1] );
    for i in [ 2 .. Length( message ) ] do
      Info( InfoPackageLoading, severity, List( currpkg, x -> ' ' ),
            "  ", message[i] );
    od;
    end );

if not IsReadOnlyGlobal( "TextAttr" ) then
  Unbind( TextAttr );
fi;


#############################################################################
##
#F  DisplayPackageLoadingLog( [<severity>] )
##
InstallGlobalFunction( DisplayPackageLoadingLog, function( arg )
    local severity, entry, message, i;

    if Length( arg ) = 0 then
      severity:= PACKAGE_WARNING;
    else
      severity:= arg[1];
    fi;

    for entry in GAPInfo.PackageLoadingMessages do
      if severity >= entry[2] then
        message:= entry[3];
        Info( InfoPackageLoading, 1, entry[1], ": ", message[1] );
        for i in [ 2 .. Length( message ) ] do
          Info( InfoPackageLoading, 1, List( entry[1], x -> ' ' ),
                "  ", message[i] );
        od;
      fi;
    od;
    end );


#############################################################################
##
#F  PackageAvailabilityInfo( <name>, <version>, <record>, <suggested> )
##
InstallGlobalFunction( PackageAvailabilityInfo,
    function( name, version, record, suggested )
    local InvalidStrongDependencies, equal, comp, pair, currversion, inforec,
          msg, dep, record_local, wght, pos, needed, test, name2;

    InvalidStrongDependencies:= function( dependencies, weights,
                                          strong_dependencies )
      local order;

      if not IsEmpty( strong_dependencies ) then
        order:= LinearOrderByPartialWeakOrder( dependencies, weights ).cycles;
        return ForAny( List( strong_dependencies, Set ),
                 pair -> ForAny( order, cycle -> IsSubset( cycle, pair ) ) );
      fi;
      return false;
    end;

    name:= LowercaseString( name );
    equal:= "";
    if 0 < Length( version ) and version[1] = '=' then
      equal:= "equal";
    fi;

    if name = "gap" then
      return CompareVersionNumbers( GAPInfo.Version, version, equal );
    fi;

    # 1. If the package `name' is already loaded then compare the version
    #    number of the loaded package with the required one.
    #    (Note that at most one version of a package can be available.)
    if IsBound( GAPInfo.PackagesLoaded.( name ) ) then
      return CompareVersionNumbers( GAPInfo.PackagesLoaded.( name )[2],
                                    version, equal );
    fi;

    # 2. Initialize the dependency info.
    for comp in [ "AlreadyHandled", "Dependencies", "StrongDependencies",
                  "InstallationPaths", "Weights" ] do
      if not IsBound( record.( comp ) ) then
        record.( comp ):= [];
      fi;
    od;

    # 3. Deal with the case that `name' is among the packages
    #    from whose tests the current check for `name' arose.
    for pair in record.AlreadyHandled do
      if name = pair[1] then
        if CompareVersionNumbers( pair[2], version, equal ) then
          # The availability of the package will be decided on an outer level.
          return fail;
        else
          # The version assumed on an outer level does not fit.
          return false;
        fi;
      fi;
    od;

    # 4. In recursive calls, regard the current package as handled,
    #    of course in the version in question.
    currversion:= [ name ];
    Add( record.AlreadyHandled, currversion );

    # 5. Get the info records for the package `name',
    #    and take the first record that satisfies the conditions.
    #    (Note that they are ordered w.r.t. descending version numbers.)
    for inforec in PackageInfo( name ) do

      currversion[2]:= inforec.Version;
      msg:= Concatenation( "PackageAvailabilityInfo for version ",
                           inforec.Version );
      if version <> "" then
        Append( msg, Concatenation( " (required: ", version, ")" ) );
      fi;
      LogPackageLoadingMessage( PACKAGE_DEBUG, msg, name );

      # Locate the `init.g' file of the package.
      if Filename( [ Directory( inforec.InstallationPath ) ], "init.g" )
           = fail  then
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            Concatenation( "PackageAvailabilityInfo: cannot locate `",
              inforec.InstallationPath,
              "/init.g', please check the installation" ), name );
        continue;
      fi;

      if IsBound( inforec.Dependencies ) then
        dep:= inforec.Dependencies;
      else
        dep:= rec();
      fi;

      record_local:= StructuralCopy( record );

      # If the GAP library is not yet loaded then assign
      # weight 0 to all packages that may be loaded before the GAP library,
      # and weight 1 to those that need the GAP library to be loaded
      # in advance.
      # The latter means that either another package or the GAP library
      # itself is forced to be loaded in advance,
      # for example because the current package has no `read.g' file.
      if Filename( [ Directory( inforec.InstallationPath ) ], "read.g" )
         = fail or
         ( not IsBound( GAPInfo.LibraryLoaded ) and
           IsBound( dep.OtherPackagesLoadedInAdvance ) and
           not IsEmpty( dep.OtherPackagesLoadedInAdvance ) ) then
        wght:= 1;
      else
        wght:= 0;
      fi;
      pos:= PositionProperty( record_local.Weights, pair -> pair[1] = name );
      if pos = fail then
        Add( record_local.Weights, [ name, wght ] );
      else
        record_local.Weights[ pos ][2]:= wght;
      fi;

      # Test whether this package version, the required GAP version,
      # and the availability test function fit.
      if not CompareVersionNumbers( inforec.Version, version, equal ) then
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            Concatenation( "PackageAvailabilityInfo: version ",
                inforec.Version, " does not fit" ), name );
        continue;
      fi;
      if IsBound( dep.GAP )
         and not CompareVersionNumbers( GAPInfo.Version, dep.GAP ) then
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            Concatenation( "PackageAvailabilityInfo: required GAP version (",
                dep.GAP, ") does not fit", name ) );
        continue;
      fi;
      GAPInfo.PackageCurrent:= inforec;
      test:= inforec.AvailabilityTest();
      Unbind( GAPInfo.PackageCurrent );
      if test <> true then
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            Concatenation( "PackageAvailabilityInfo: the AvailabilityTest",
                " function returned ", String( test ) ), name );
        continue;
      fi;

      # Check the dependencies of this package version.
      needed:= [];
      if IsBound( dep.OtherPackagesLoadedInAdvance ) then
        Append( record_local.StrongDependencies,
                List( dep.OtherPackagesLoadedInAdvance,
                      x -> [ LowercaseString( x[1] ), name ] ) );
        Append( needed, dep.OtherPackagesLoadedInAdvance );
      fi;
      if IsBound( dep.NeededOtherPackages ) then
        Append( needed, dep.NeededOtherPackages );
      fi;
      test:= true;
      for pair in needed do
        name2:= LowercaseString( pair[1] );
        test:= PackageAvailabilityInfo( name2, pair[2], record_local,
                   suggested );
        if test = false then
          # This dependency cannot be satisfied, skip the others.
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              Concatenation( "PackageAvailabilityInfo: dependency ",
                  name2, " cannot be satisfied" ), name );
          break;
        elif test <> true then
          # The package `name2' is available but not yet loaded.
          Add( record_local.Dependencies, [ name2, name ] );
        fi;
      od;
      if test = false then
        # Some package needed by this version is not available,
        continue;
      fi;

      if InvalidStrongDependencies( record_local.Dependencies,
             record_local.Weights, record_local.StrongDependencies ) then
        # This package version cannot be loaded due to conditions
        # imposed by `OtherPackagesLoadedInAdvance' components.
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            Concatenation( "PackageAvailabilityInfo: some condition from ",
                "OtherPackagesLoadedInAdvance cannot be satisfied" ), name );
        continue;
      fi;

      # The version given by `inforec' will be taken.
      # Copy the information back to the argument record.
      record.InstallationPaths:= record_local.InstallationPaths;
      Add( record.InstallationPaths,
           [ name, [ inforec.InstallationPath, inforec.Version,
                     inforec.PackageName ] ] );
      record.Dependencies:= record_local.Dependencies;
      record.StrongDependencies:= record_local.StrongDependencies;
      record.AlreadyHandled:= record_local.AlreadyHandled;
      record.Weights:= record_local.Weights;

      if suggested and IsBound( dep.SuggestedOtherPackages ) then
        # Collect info about suggested packages and their dependencies.
        for pair in dep.SuggestedOtherPackages do
          name2:= LowercaseString( pair[1] );
          # Do not change the information collected up to now
          # until we are sure that we will really use the suggested package.
          record_local:= StructuralCopy( record );
          test:= PackageAvailabilityInfo( name2, pair[2], record_local,
                     suggested );
          if test <> true then
            Add( record_local.Dependencies, [ name2, name ] );
            if IsString( test ) then
              if InvalidStrongDependencies( record_local.Dependencies,
                     record_local.Weights,
                     record_local.StrongDependencies ) then
                test:= false;
              fi;
            fi;
            if test <> false then
              record.InstallationPaths:= record_local.InstallationPaths;
              record.Dependencies:= record_local.Dependencies;
              record.StrongDependencies:= record_local.StrongDependencies;
              record.AlreadyHandled:= record_local.AlreadyHandled;
              record.Weights:= record_local.Weights;
            fi;
          fi;
        od;
      fi;

      # Print a warning if the package should better be upgraded.
      if IsBound( GAPInfo.PackagesRestrictions.( name ) ) then
        GAPInfo.PackagesRestrictions.( name ).OnLoad( inforec );
      fi;
#T component name OnLoad:
#T shouldn't this be done only if the package is actually loaded?

      LogPackageLoadingMessage( PACKAGE_DEBUG,
          Concatenation( "PackageAvailabilityInfo: version ",
                         inforec.Version, " is available" ), name );

      return inforec.InstallationPath;

    od;

    # No info record satisfies the requirements.
    if not IsBound( GAPInfo.PackagesInfo.( name ) ) then
      inforec:= First( GAPInfo.PackagesInfoRefuseLoad,
                       r -> LowercaseString( r.PackageName ) = name );
      if inforec <> fail then
        # Some versions are installed but all were refused.
        GAPInfo.PackagesRestrictions.( name ).OnLoad( inforec );
      fi;
    fi;

    LogPackageLoadingMessage( PACKAGE_DEBUG,
        Concatenation( "PackageAvailabilityInfo: ",
            "no installed version fits" ), name );

    return false;
end );


#############################################################################
##
#F  TestPackageAvailability( <name>, <version> )
##
##  In earlier versions, this function had an optional third argument,
##  which is now ignored.
##
InstallGlobalFunction( TestPackageAvailability, function( arg )
    local name, version, result;

    # Get the arguments.
    name:= LowercaseString( arg[1] );
    if 1 < Length( arg ) then
      version:= arg[2];
    else
      version:= "";
    fi;

    # Ignore suggested packages.
    result:= PackageAvailabilityInfo( name, version, rec(), false );

    if result = false then
      return fail;
    else
      return result;
    fi;
    end );


#############################################################################
##
#F  IsPackageMarkedForLoading( <name>, <version> )
##
InstallGlobalFunction( IsPackageMarkedForLoading, function( name, version )
    local equal;

    equal:= "";
    if 0 < Length( version ) and version[1] = '=' then
      equal:= "equal";
    fi;
    name:= LowercaseString( name );
    return IsBound( GAPInfo.PackagesLoaded.( name ) )
           and CompareVersionNumbers( GAPInfo.PackagesLoaded.( name )[2],
                   version, equal );
    end );


#############################################################################
##
#F  DefaultPackageBannerString( <inforec> )
##
InstallGlobalFunction( DefaultPackageBannerString, function( inforec )
    local sep, str, authors, role, fill, i, person;

    # Start with a row of `-' signs.
    sep:= ListWithIdenticalEntries( SizeScreen()[1] - 3, '-' );
    Add( sep, '\n' );
    str:= ShallowCopy( sep );

    # Add package name and version number.
    if IsBound( inforec.PackageName ) and IsBound( inforec.Version ) then
      Append( str, Concatenation(
              "Loading  ", inforec.PackageName, " ", inforec.Version ) );
    fi;

    # Add the long title.
    if IsBound( inforec.PackageDoc[1] ) and
       IsBound( inforec.PackageDoc[1].LongTitle ) and
       not IsEmpty( inforec.PackageDoc[1].LongTitle ) then
      Append( str, Concatenation(
              " (", inforec.PackageDoc[1].LongTitle, ")" ) );
    fi;
    Add( str, '\n' );

    # Add info about the authors if there are authors;
    # otherwise add maintainers.
    if IsBound( inforec.Persons ) then
      authors:= Filtered( inforec.Persons, x -> x.IsAuthor );
      role:= "by ";
      if IsEmpty( authors ) then
        authors:= Filtered( inforec.Persons, x -> x.IsMaintainer );
        role:= "maintained by ";
      fi;
      fill:= List( role, x -> ' ' );
      Append( str, role );
      for i in [ 1 .. Length( authors ) ] do
        person:= authors[i];
        Append( str, person.FirstNames );
        Append( str, " " );
        Append( str, person.LastName );
        if   IsBound( person.WWWHome ) then
          Append( str, Concatenation( " (", person.WWWHome, ")" ) );
        elif IsBound( person.Email ) then
          Append( str, Concatenation( " (", person.Email, ")" ) );
        fi;
        if   i = Length( authors ) then
          Append( str, ".\n" );
        elif i = Length( authors )-1 then
          if i = 1 then
            Append( str, " and\n" );
          else
            Append( str, ", and\n" );
          fi;
          Append( str, fill );
        else
          Append( str, ",\n" );
          Append( str, fill );
        fi;
      od;
    fi;

    # Add info about the home page of the package.
    if IsBound( inforec.WWWHome ) then
      Append( str, "(See also " );
      Append( str, inforec.PackageWWWHome );
      Append( str, ".)\n" );
    fi;

    Append( str, sep );

    str:= ReplacedString( str, "&auml;", "\"a" );
    str:= ReplacedString( str, "&ouml;", "\"o" );
    str:= ReplacedString( str, "&uuml;", "\"u" );

    return str;
    end );


#############################################################################
##
#F  DirectoriesPackagePrograms( <name> )
##
InstallGlobalFunction( DirectoriesPackagePrograms, function( name )
    local arch, dirs, info, version, r, path;

    arch := GAPInfo.Architecture;
    dirs := [];
    # We are not allowed to call
    # `InstalledPackageVersion', `TestPackageAvailability' etc.
    info:= PackageInfo( name );
    if IsBound( GAPInfo.PackagesLoaded.( name ) ) then
      # The package is already loaded.
      version:= GAPInfo.PackagesLoaded.( name )[2];
    elif IsBound( GAPInfo.PackageCurrent ) then
      # The package is currently going to be loaded.
      version:= GAPInfo.PackageCurrent.Version;
    elif 0 < Length( info ) then
      # Take the installed package with the highest version.
      version:= info[1].Version;
    fi;
    for r in info do
      if r.Version = version then
        path:= Concatenation( r.InstallationPath, "/bin/", arch, "/" );
        Add( dirs, Directory( path ) );
      fi;
    od;
    return dirs;
end );


#############################################################################
##
#F  DirectoriesPackageLibrary( <name>[, <path>] )
##
InstallGlobalFunction( DirectoriesPackageLibrary, function( arg )
    local name, path, dirs, info, version, r, tmp;

    if IsEmpty(arg) or 2 < Length(arg) then
        Error( "usage: DirectoriesPackageLibrary( <name>[, <path>] )\n" );
    elif not ForAll(arg, IsString) then
        Error( "string argument(s) expected\n" );
    fi;

    name:= LowercaseString( arg[1] );
    if '\\' in name or ':' in name  then
        Error( "<name> must not contain '\\' or ':'" );
    elif 1 = Length(arg)  then
        path := "lib";
    else
        path := arg[2];
    fi;

    dirs := [];
    # We are not allowed to call
    # `InstalledPackageVersion', `TestPackageAvailability' etc.
    info:= PackageInfo( name );
    if IsBound( GAPInfo.PackagesLoaded.( name ) ) then
      # The package is already loaded.
      version:= GAPInfo.PackagesLoaded.( name )[2];
    elif IsBound( GAPInfo.PackageCurrent ) then
      # The package is currently going to be loaded.
      version:= GAPInfo.PackageCurrent.Version;
    elif 0 < Length( info ) then
      # Take the installed package with the highest version.
      version:= info[1].Version;
    fi;
    for r in info do
      if r.Version = version then
        tmp:= Concatenation( r.InstallationPath, "/", path );
        if IsDirectoryPath( tmp ) = true then
          Add( dirs, Directory( tmp ) );
        fi;
      fi;
    od;
    return dirs;
end );


#############################################################################
##
#F  ReadPackage( [<name>, ]<file> )
#F  RereadPackage( [<name>, ]<file> )
##
InstallGlobalFunction( ReadPackage, function( arg )
    local pos, relpath, pkgname, namespace, filename, rflc, rfc;

    # Note that we cannot use `ReadAndCheckFunc' because this calls
    # `READ_GAP_ROOT', but here we have to read the file in one of those
    # directories where the package version resides that has been loaded
    # or (at least currently) would be loaded.
    if   Length( arg ) = 1 then
      # Guess the package name.
      pos:= Position( arg[1], '/' );
      relpath:= arg[1]{ [ pos+1 .. Length( arg[1] ) ] };
      pkgname:= LowercaseString( arg[1]{ [ 1 .. pos-1 ] } );
      namespace := GAPInfo.PackagesInfo.(pkgname)[1].PackageName;
    elif Length( arg ) = 2 then
      pkgname:= LowercaseString( arg[1] );
      namespace := GAPInfo.PackagesInfo.(pkgname)[1].PackageName;
      relpath:= arg[2];
    else
      Error( "expected 1 or 2 arguments" );
    fi;

    # Note that `DirectoriesPackageLibrary' finds the file relative to the
    # installation path of the info record chosen in `LoadPackage'.
    filename:= Filename( DirectoriesPackageLibrary( pkgname, "" ), relpath );
    if filename <> fail and IsReadableFile( filename ) then
      ENTER_NAMESPACE(namespace);
      Read( filename );
      LEAVE_NAMESPACE();
      return true;
    else
      return false;
    fi;
    end );

InstallGlobalFunction( RereadPackage, function( arg )
    local res;

    MakeReadWriteGlobal( "REREADING" );
    REREADING:= true;
    MakeReadOnlyGlobal( "REREADING" );
    res:= CallFuncList( ReadPackage, arg );
    MakeReadWriteGlobal( "REREADING" );
    REREADING:= false;
    MakeReadOnlyGlobal( "REREADING" );
    return res;
    end );


#############################################################################
##
#F  LoadPackageDocumentation( <info> )
##
##  In versions before 4.5, a second argument was required.
##  For the sake of backwards compatibility, we do not forbid a second
##  argument, but we ignore it.
##  (In later versions, we may forbid the second argument.)
##
InstallGlobalFunction( LoadPackageDocumentation, function( arg )
    local info, short, pkgdoc, long, sixfile;

    info:= arg[1];

    # Load all books for the package.
    for pkgdoc in info.PackageDoc do
      # Fetch the names.
      if IsBound( pkgdoc.LongTitle ) then
        long:= pkgdoc.LongTitle;
      else
        long:= Concatenation( "GAP Package `", info.PackageName, "'" );
      fi;
      short:= pkgdoc.BookName;
      if not IsBound( GAPInfo.PackagesLoaded.( LowercaseString(
                          info.PackageName ) ) ) then
        short:= Concatenation( short, " (not loaded)" );
      fi;

      # Check that the `manual.six' file is available.
      sixfile:= Filename( [ Directory( info.InstallationPath ) ],
                          pkgdoc.SixFile );
      if sixfile = fail then
        LogPackageLoadingMessage( PACKAGE_INFO,
            Concatenation( [ "book `", pkgdoc.BookName,
                "': no manual index file `",
                pkgdoc.SixFile, "', ignored" ] ),
            info.PackageName );
      else
        # Finally notify the book via its directory.
#T Here we assume that this is the directory that contains also `manual.six'!
        HELP_ADD_BOOK( short, long,
            Directory( sixfile{ [ 1 .. Length( sixfile )-10 ] } ) );
      fi;
    od;
    end );


#############################################################################
##
#F  LoadPackage( <name>[, <version>][, <banner>] )
##
BindGlobal( "LoadPackage_ReadImplementationParts",
    function( secondrun, banner )
    local pair, info, bannerstring, fun, u, pkgname, namespace;

    for pair in secondrun do
      GAPInfo.PackageCurrent:= pair[1];
      namespace := pair[1].PackageName;
      pkgname := LowercaseString( namespace );
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "start reading file read.g",
          namespace );
      ENTER_NAMESPACE(namespace);
      Read( pair[2] );
      LEAVE_NAMESPACE();
      Unbind( GAPInfo.PackageCurrent );
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "finish reading file read.g",
          namespace );
    od;

    # Show the banners.
    if banner then
      for pair in secondrun do
        info:= pair[1];

        # If the component `BannerString' is bound in `info' then we print
        # this string, otherwise we print the default banner string.
        if IsBound( info.BannerString ) then
          bannerstring:= info.BannerString;
        else
          bannerstring:= DefaultPackageBannerString( info );
        fi;

        # Be aware of umlauts, accents etc. in the banner.
        if IsBoundGlobal( "Unicode" ) and IsBoundGlobal( "Encode" ) then
          # The GAPDoc package is completely loaded.
          fun:= ValueGlobal( "Unicode" );
          u:= fun( bannerstring, "UTF-8" );
          if u = fail then
            u:= fun( bannerstring, "ISO-8859-1");
          fi;
          fun:= ValueGlobal( "Encode" );
          Print( fun( u, GAPInfo.TermEncoding ) );
        else
          # GAPDoc is not available, simply print the banner string as is.
          Print( bannerstring );
        fi;
      od;
    fi;
    end );

InstallGlobalFunction( LoadPackage, function( arg )
    local name, version, banner, loadsuggested, msg, depinfo, path, pair, i,
          order, paths, cycle, secondrun, pkgname, pos, info, filename, read;

    # Get the arguments.
    name:= LowercaseString( arg[1] );
    version:= "";
    banner:= not GAPInfo.CommandLineOptions.q and
             not GAPInfo.CommandLineOptions.b;
    if 1 < Length( arg ) then
      if IsString( arg[2] ) then
        version:= arg[2];
        if 2 < Length( arg ) then
          banner:= banner and not ( arg[3] = false );
        fi;
      else
        banner:= banner and not ( arg[2] = false );
      fi;
    fi;
    loadsuggested:= ( ValueOption( "OnlyNeeded" ) <> true );

    # Print a warning if `LoadPackage' is called inside a
    # `LoadPackage' call.
    if not IsBound( GAPInfo.LoadPackageLevel ) then
      GAPInfo.LoadPackageLevel:= 0;
    fi;
    GAPInfo.LoadPackageLevel:= GAPInfo.LoadPackageLevel + 1;
    if GAPInfo.LoadPackageLevel <> 1 then
      if IsBound( GAPInfo.PackageCurrent ) then
        msg:= GAPInfo.PackageCurrent.PackageName;
      else
        msg:= "?";
      fi;
      LogPackageLoadingMessage( PACKAGE_WARNING,
          [ Concatenation( "Do not call `LoadPackage( \"", name,
                "\", ... )' inside a package file," ),
            "use `IsPackageMarkedForLoading' instead" ], msg );
    fi;

    # Start logging.
    msg:= "entering LoadPackage ";
    if not loadsuggested then
      Append( msg, " (omitting suggested packages)" );
    fi;
    LogPackageLoadingMessage( PACKAGE_DEBUG, msg, name );

    # Test whether the package is available,
    # and compute the dependency information.
    depinfo:= rec();
    path:= PackageAvailabilityInfo( name, version, depinfo, loadsuggested );
    if not IsString( path ) then
      if path = false then
        path:= fail;
      fi;
      # The result is either `true' (the package is already loaded)
      # or `fail' (the package cannot be loaded).
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          Concatenation( "return from LoadPackage, ",
              "PackageAvailabilityInfo returned ", String( path ) ), name );
      GAPInfo.LoadPackageLevel:= GAPInfo.LoadPackageLevel - 1;
      return path;
    fi;

    # First mark all packages in question as loaded,
    # in order to avoid that an occasional call of `LoadPackage'
    # inside the package code causes the files to be read more than once.
    for pair in depinfo.InstallationPaths do
      GAPInfo.PackagesLoaded.( pair[1] ):= pair[2];
#T Remove the following as soon as the obsolete variable has been removed!
if IsBoundGlobal( "PACKAGES_VERSIONS" ) then
  ValueGlobal( "PACKAGES_VERSIONS" ).( pair[1] ):= pair[2][2];
fi;
    od;

    # Compute the order in which the packages are loaded.
    # For each set of packages with cyclic dependencies,
    # read first all `init.g' files and then all `read.g' files.
    if IsEmpty( depinfo.Dependencies ) then
      order:= rec( cycles:= [ [ name ] ],
                   weights:= [ depinfo.Weights[1][2] ] );
    else
      order:= LinearOrderByPartialWeakOrder( depinfo.Dependencies,
                                             depinfo.Weights );
    fi;
    # paths:= TransposedMatMutable( depinfo.InstallationPaths );
    # (TransposedMatMutable is not yet available here ...)
    paths:= [ [], [] ];
    for pair in depinfo.InstallationPaths do
      Add( paths[1], pair[1] );
      Add( paths[2], pair[2] );
    od;
    SortParallel( paths[1], paths[2] );

    secondrun:= [];
    for i in [ 1 .. Length( order.cycles ) ] do
      cycle:= order.cycles[i];

      # If the weight is 1 and the GAP library is not yet loaded
      # then load the GAP library now.
      if order.weights[i] = 1 and not IsBound( GAPInfo.LibraryLoaded ) then
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            [ "read the impl. part of the GAP library" ], name );
        ReadGapRoot( "lib/read.g" );
        GAPInfo.LibraryLoaded:= true;
        LoadPackage_ReadImplementationParts( Concatenation(
            GAPInfo.delayedImplementationParts, secondrun ), false );
        GAPInfo.delayedImplementationParts:= [];
        secondrun:= [];
      fi;

      LogPackageLoadingMessage( PACKAGE_DEBUG,
          Concatenation( [ "start loading needed/suggested/self packages" ],
              cycle ),
          name );

      for pkgname in cycle do
        pos:= PositionSorted( paths[1], pkgname );
        info:= First( PackageInfo( pkgname ),
                      r -> r.InstallationPath = paths[2][ pos ][1] );

        # This is the first attempt to read stuff for this package.
        # So we handle the case of a `PreloadFile' entry.
        if IsBound( info.PreloadFile ) then
          filename:= USER_HOME_EXPAND( info.PreloadFile );
          if filename[1] = '/' then
            read:= READ( filename );
          else
            read:= ReadPackage( name, filename );
          fi;
          if not read then
            LogPackageLoadingMessage( PACKAGE_WARNING,
                Concatenation( "file `", filename, "' cannot be read" ),
                pkgname );
          fi;
        fi;

        # Notify the documentation (for the available version).
        LoadPackageDocumentation( info );

        # Read the `init.g' files.
        LogPackageLoadingMessage( PACKAGE_DEBUG, "start reading file init.g",
            pkgname );
        GAPInfo.PackageCurrent:= info;
        ReadPackage( pkgname, "init.g" );
        Unbind( GAPInfo.PackageCurrent );
        LogPackageLoadingMessage( PACKAGE_DEBUG, "finish reading file init.g",
            pkgname );

        filename:= Filename( [ Directory( info.InstallationPath ) ],
                             "read.g" );
        if filename <> fail then
          Add( secondrun, [ info, filename ] );
        fi;
      od;

      if IsBound( GAPInfo.LibraryLoaded )
         and GAPInfo.LibraryLoaded = true then
        # Read the `read.g' files collected up to now.
        # Afterwards show the banners.
        # (We have delayed this until now because it uses functionality
        # from the package GAPDoc.)
        # Note that no banners are printed during autoloading.
        LoadPackage_ReadImplementationParts( secondrun, banner );
        secondrun:= [];
      fi;

    od;

    if not IsBound( GAPInfo.LibraryLoaded ) then
      Append( GAPInfo.delayedImplementationParts, secondrun );
    fi;

    LogPackageLoadingMessage( PACKAGE_DEBUG, "return from LoadPackage",
        name );
    GAPInfo.LoadPackageLevel:= GAPInfo.LoadPackageLevel - 1;
    return true;
    end );


#############################################################################
##
#F  LoadAllPackages()
##
InstallGlobalFunction( LoadAllPackages, function()
    List( RecNames( GAPInfo.PackagesInfo ), LoadPackage );
    end );


#############################################################################
##
#F  SetPackagePath( <pkgname>, <pkgpath> )
##
InstallGlobalFunction( SetPackagePath, function( pkgname, pkgpath )
    local pkgdir, file, record, version;

    InitializePackagesInfoRecords();
    pkgname:= LowercaseString( pkgname );
    NormalizeWhitespace( pkgname );
    if IsBound( GAPInfo.PackagesLoaded.( pkgname ) ) then
      if GAPInfo.PackagesLoaded.( pkgname )[1] = pkgpath then
        return;
      fi;
      Error( "another version of package ", pkgname, " is already loaded" );
    fi;

    pkgdir:= Directory( pkgpath );
    file:= Filename( [ pkgdir ], "PackageInfo.g" );
    if file = fail then
      file:= Filename( [ pkgdir ], "PkgInfo.g" );
    fi;
    if file = fail then
      return;
    fi;
    Unbind( GAPInfo.PackageInfoCurrent );
    Read( file );
    record:= GAPInfo.PackageInfoCurrent;
    Unbind( GAPInfo.PackageInfoCurrent );
    if IsBound( record.PkgName ) then
      record.PackageName:= record.PkgName;
    fi;
    if pkgname <> NormalizedWhitespace( LowercaseString(
                      record.PackageName ) ) then
      Error( "found package ", record.PackageName, " not ", pkgname,
             " in ", pkgpath );
    fi;
    version:= record.Version;
    if IsBound( GAPInfo.PackagesRestrictions.( pkgname ) )
       and GAPInfo.PackagesRestrictions.( pkgname ).OnInitialization(
               record ) = false  then
      Add( GAPInfo.PackagesInfoRefuseLoad, record );
    else
      record.InstallationPath:= Filename( [ pkgdir ], "" );
      if not IsBound( record.PackageDoc ) then
        record.PackageDoc:= [];
      elif IsRecord( record.PackageDoc ) then
        record.PackageDoc:= [ record.PackageDoc ];
      fi;
    fi;
    GAPInfo.PackagesInfo.( pkgname ):= [ record ];
    end );


#############################################################################
##
#F  ExtendRootDirectories( <paths> )
##
InstallGlobalFunction( ExtendRootDirectories, function( rootpaths )
    rootpaths:= Filtered( rootpaths, path -> not path in GAPInfo.RootPaths );
    if not IsEmpty( rootpaths ) then
      # Append the new root paths.
      GAPInfo.RootPaths:= Immutable( Concatenation( GAPInfo.RootPaths,
          rootpaths ) );
      # Clear the cache.
      GAPInfo.DirectoriesLibrary:= rec();
      # Deal with an obsolete variable.
      if IsBoundGlobal( "GAP_ROOT_PATHS" ) then
        MakeReadWriteGlobal( "GAP_ROOT_PATHS" );
        UnbindGlobal( "GAP_ROOT_PATHS" );
        BindGlobal( "GAP_ROOT_PATHS", GAPInfo.RootPaths );
      fi;
      # Reread the package information.
      if IsBound( GAPInfo.PackagesInfoInitialized ) and
         GAPInfo.PackagesInfoInitialized = true then
        GAPInfo.PackagesInfoInitialized:= false;
        InitializePackagesInfoRecords();
      fi;
    fi;
    end );


#############################################################################
##
#F  InstalledPackageVersion( <name> )
##
InstallGlobalFunction( InstalledPackageVersion, function( name )
    local avail, info;

    avail:= TestPackageAvailability( name, "" );
    if   avail = fail then
      return fail;
    elif avail = true then
      return GAPInfo.PackagesLoaded.( LowercaseString( name ) )[2];
    fi;
    info:= First( PackageInfo( name ), r -> r.InstallationPath = avail );
    return info.Version;
    end );


#############################################################################
##
#F  AutoloadPackages()
##
InstallGlobalFunction( AutoloadPackages, function()
    local banner, pair, excludedpackages, name, record;

#T remove this as soon as `BANNER' is not used anymore in packages
if IsBoundGlobal( "BANNER" ) then
  banner:= ValueGlobal( "BANNER" );
  MakeReadWriteGlobal( "BANNER" );
  UnbindGlobal( "BANNER" );
fi;
BindGlobal( "BANNER", false );

    GAPInfo.delayedImplementationParts:= [];

    # Load the needed other packages (suppressing banners)
    # that are not yet loaded.
    if ForAny( GAPInfo.Dependencies.NeededOtherPackages,
               p -> not IsBound( GAPInfo.PackagesLoaded.( p[1] ) ) ) then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "trying to load needed packages", "GAP" );
      if GAPInfo.CommandLineOptions.A then
        PushOptions( rec( OnlyNeeded:= true ) );
      fi;
      for pair in GAPInfo.Dependencies.NeededOtherPackages do
        if LoadPackage( pair[1], pair[2], false ) <> true then
          LogPackageLoadingMessage( PACKAGE_ERROR, Concatenation(
              "needed package ", pair[1], " cannot be loaded" ), "GAP" );
          Error( "failed to load needed package `", pair[1],
                 "' (version ", pair[2], ")" );
        fi;
      od;
      LogPackageLoadingMessage( PACKAGE_DEBUG, "needed packages loaded",
          "GAP" );
      if GAPInfo.CommandLineOptions.A then
        PopOptions();
      fi;
    fi;

    if GAPInfo.CommandLineOptions.A or ValueOption( "OnlyNeeded" ) = true then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "omitting suggested packages", "GAP" );
    else
      excludedpackages:= List( GAPInfo.UserPreferences.ExcludeFromAutoload,
                               LowercaseString );

      if ForAny( GAPInfo.Dependencies.SuggestedOtherPackages,
                 p -> not IsBound( GAPInfo.PackagesLoaded.( p[1] ) ) ) then
        # Try to load the suggested other packages (suppressing banners),
        # issue a warning for each such package where this is not possible.
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            Concatenation( [ "trying to load suggested packages" ],
                List( GAPInfo.Dependencies.SuggestedOtherPackages,
                    pair -> Concatenation( pair[1], " (", pair[2], ")" ) ) ),
            "GAP" );
        for pair in GAPInfo.Dependencies.SuggestedOtherPackages do
          if LowercaseString( pair[1] ) in excludedpackages then
            LogPackageLoadingMessage( PACKAGE_DEBUG,
                Concatenation( "excluded from autoloading: ", pair[1] ),
                "GAP" );
          else
            LogPackageLoadingMessage( PACKAGE_DEBUG,
                Concatenation( "considering for autoloading: ", pair[1] ),
                "GAP" );
            if LoadPackage( pair[1], pair[2], false ) <> true then
              LogPackageLoadingMessage( PACKAGE_DEBUG,
                   Concatenation( "suggested package ", pair[1],
                       " (version ", pair[2], ") cannot be loaded" ), "GAP" );
            fi;
            LogPackageLoadingMessage( PACKAGE_DEBUG,
                Concatenation( pair[1], " loaded" ), "GAP" );
          fi;
        od;
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            "suggested packages loaded", "GAP" );
      fi;
    fi;

    # Load the documentation for not yet loaded packages.
    for name in RecNames( GAPInfo.PackagesInfo ) do
      if not IsBound( GAPInfo.PackagesLoaded.( name ) ) then
        # Note that the info records for each package are sorted
        # w.r.t. decreasing version number.
        record:= First( GAPInfo.PackagesInfo.( name ), IsRecord );
        if record <> fail then
          LoadPackageDocumentation( record );
        fi;
      fi;
    od;

    # If necessary then load the implementation part of the GAP library,
    # and the implementation parts of the packages loaded up to now.
    if not IsBound( GAPInfo.LibraryLoaded ) then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          [ "read the impl. part of the GAP library" ], "GAP" );
      ReadGapRoot( "lib/read.g" );
      GAPInfo.LibraryLoaded:= true;
      GAPInfo.LoadPackageLevel:= GAPInfo.LoadPackageLevel + 1;
      LoadPackage_ReadImplementationParts(
          GAPInfo.delayedImplementationParts, false );
      GAPInfo.LoadPackageLevel:= GAPInfo.LoadPackageLevel - 1;
    fi;
    Unbind( GAPInfo.delayedImplementationParts );

#T remove this as soon as `BANNER' is not used anymore in packages
MakeReadWriteGlobal( "BANNER" );
UnbindGlobal( "BANNER" );
if IsBound( banner ) then
  BindGlobal( "BANNER", banner );
fi;
    end );


#############################################################################
##
#F  GAPDocManualLab(<pkgname>) . create manual.lab for package w/ GAPDoc docs
##
# avoid warning (will be def. in GAPDoc)
if not IsBound(StripEscapeSequences) then
  StripEscapeSequences := 0;
fi;
InstallGlobalFunction( GAPDocManualLabFromSixFile,
    function( bookname, sixfilepath )
    local stream, entries, SecNumber, esctex, file;

    stream:= InputTextFile( sixfilepath );
    entries:= HELP_BOOK_HANDLER.GapDocGAP.ReadSix( stream ).entries;
    SecNumber:= function( list )
      if IsEmpty( list ) or list[1] = 0 then
        return "";
      fi;
      while list[ Length( list ) ] = 0 do
        Unbind( list[ Length( list ) ] );
      od;
      return JoinStringsWithSeparator( List( list, String ), "." );
    end;

    # throw away TeX critical characters here
    esctex:= function( str )
      return Filtered( StripEscapeSequences( str ), c -> not c in "%#$&^_~" );
    end;

    bookname:= LowercaseString( bookname );
    entries:= List( entries,
                     entry -> Concatenation( "\\makelabel{", bookname, ":",
                                             esctex(entry[1]), "}{",
                                             SecNumber( entry[3] ), "}\n" ) );
    # forget entries that contain a character from "\\*+/=" in label,
    # these were never allowed, so no old manual will refer to them
    entries := Filtered(entries, entry ->
                    not ForAny("\\*+/=", c-> c in entry{[9..Length(entry)]}));
    file:= Concatenation( sixfilepath{ [ 1 .. Length( sixfilepath ) - 3 ] },
                          "lab" );
    FileString( file, Concatenation( entries ) );
    Info( InfoWarning, 1, "File: ", file, " written." );
end );

InstallGlobalFunction( GAPDocManualLab, function(pkgname)
  local pinf, book, file;

  if not IsString(pkgname) then
    Error("argument <pkgname> should be a string\n");
  fi;
  pkgname := LowercaseString(pkgname);
  LoadPackage(pkgname);
  if not IsBound(GAPInfo.PackagesInfo.(pkgname)) then
    Error("Could not load package ", pkgname, ".\n");
  fi;
  if LoadPackage("GAPDoc") <> true then
    Error("package `GAPDoc' not installed. Please install `GAPDoc'\n" );
  fi;

  pinf := GAPInfo.PackagesInfo.(pkgname)[1];
  for book in pinf.PackageDoc do
    file := Filename([Directory(pinf.InstallationPath)], book.SixFile);
    if file = fail or not IsReadableFile(file) then
      Error("could not open `manual.six' file of package `", pkgname, "'.\n",
            "Please compile its documentation\n");
    fi;
    GAPDocManualLabFromSixFile( book.BookName, file );
  od;
end );
if StripEscapeSequences = 0 then
  Unbind(StripEscapeSequences);
fi;


#############################################################################
##
#F  DeclareAutoreadableVariables( <pkgname>, <filename>, <varlist> )
##
InstallGlobalFunction( DeclareAutoreadableVariables,
    function( pkgname, filename, varlist )
    CallFuncList( AUTO, Concatenation( [
      function( x )
        # Avoid nested calls to `RereadPackage',
        # which could cause that `REREADING' is set to `false' too early.
        if REREADING then
          ReadPackage( pkgname, filename );
        else
          RereadPackage( pkgname, filename );
        fi;
      end, filename ], varlist ) );
    end );


#############################################################################
##
##  Tests whether loading a package works and does not obviously break
##  anything.
##  (This is very preliminary.)
##


#############################################################################
##
#F  ValidatePackageInfo( <record> )
#F  ValidatePackageInfo( <filename> )
##
InstallGlobalFunction( ValidatePackageInfo, function( record )
    local IsStringList, IsRecordList, IsProperBool,
          result,
          TestOption, TestMandat,
          subrec, list;

    if IsString( record ) then
      if IsReadableFile( record ) then
        Unbind( GAPInfo.PackageInfoCurrent );
        Read( record );
        if IsBound( GAPInfo.PackageInfoCurrent ) then
          record:= GAPInfo.PackageInfoCurrent;
          Unbind( GAPInfo.PackageInfoCurrent );
        else
          Error( "the file <record> is not a `PackageInfo.g' file" );
        fi;
      else
        Error( "<record> is not the name of a readable file" );
      fi;
    elif not IsRecord( record ) then
      Error( "<record> must be either a record or a filename" );
    fi;

    IsStringList:= x -> IsList( x ) and ForAll( x, IsString );
    IsRecordList:= x -> IsList( x ) and ForAll( x, IsRecord );
    IsProperBool:= x -> x = true or x = false;

    result:= true;

    TestOption:= function( record, name, type, typename )
    if IsBound( record.( name ) ) and not type( record.( name ) ) then
      Print( "#E  component `", name, "', if present, must be bound to ",
             typename, "\n" );
      result:= false;
      return false;
    fi;
    return true;
    end;

    TestMandat:= function( record, name, type, typename )
    if not IsBound( record.( name ) ) or not type( record.( name ) ) then
      Print( "#E  component `", name, "' must be bound to ",
             typename, "\n" );
      result:= false;
      return false;
    fi;
    return true;
    end;

    TestMandat( record, "PackageName",
        x -> IsString(x) and 0 < Length(x),
        "a nonempty string" );
    TestMandat( record, "Subtitle", IsString, "a string" );
    TestMandat( record, "Version",
        x -> IsString(x) and 0 < Length(x) and x[1] <> '=',
        "a nonempty string that does not start with `='" );
    TestMandat( record, "Date",
        x -> IsString(x) and Length(x) = 10 and x{ [3,6] } = "//"
                 and ForAll( x{ [1,2,4,5,7,8,9,10] }, IsDigitChar ),
        "a string of the form `dd/mm/yyyy'" );
    TestMandat( record, "ArchiveURL", IsString, "a string" );
    TestMandat( record, "ArchiveFormats", IsString, "a string" );
    TestOption( record, "TextFiles", IsStringList, "a list of strings" );
    TestOption( record, "BinaryFiles", IsStringList, "a list of strings" );
    if     TestOption( record, "Persons", IsRecordList, "a list of records" )
       and IsBound( record.Persons ) then
      for subrec in record.Persons do
        TestMandat( subrec, "LastName", IsString, "a string" );
        TestMandat( subrec, "FirstNames", IsString, "a string" );
        if not (    IsBound( subrec.IsAuthor )
                 or IsBound( subrec.IsMaintainer ) ) then
          Print( "#E  one of the components `IsAuthor', `IsMaintainer' ",
                 "must be bound\n" );
          result:= false;
        fi;
        TestOption( subrec, "IsAuthor", IsProperBool, "`true' or `false'" );
        TestOption( subrec, "IsMaintainer", IsProperBool,
            "`true' or `false'" );

        if not (    IsBound( subrec.Email ) or IsBound( subrec.WWWHome )
                 or IsBound( subrec.PostalAddress ) ) then
          Print( "#E  one of the components `Email', `WWWHome', ",
                 "`PostalAddress' must be bound\n" );
          result:= false;
        fi;
        TestOption( subrec, "Email", IsString, "a string" );
        TestOption( subrec, "WWWHome", IsString, "a string" );
        TestOption( subrec, "PostalAddress", IsString, "a string" );
        TestOption( subrec, "Place", IsString, "a string" );
        TestOption( subrec, "Institution", IsString, "a string" );
      od;
    fi;

    if TestMandat( record, "Status",
           x -> x in [ "accepted", "deposited", "dev", "other" ],
           "one of \"accepted\", \"deposited\", \"dev\", \"other\"" )
       and record.Status = "accepted" then
      TestMandat( record, "CommunicatedBy",
          x -> IsString(x) and PositionSublist( x, " (" ) <> fail
                   and x[ Length(x) ] = ')',
          "a string of the form `<name> (<place>)'" );
      TestMandat( record, "AcceptDate",
          x -> IsString( x ) and Length( x ) = 7 and x[3] = '/'
                   and ForAll( x{ [1,2,4,5,6,7] }, IsDigitChar ),
          "a string of the form `mm/yyyy'" );
    fi;
    TestMandat( record, "README_URL", IsString, "a string" );
    TestMandat( record, "PackageInfoURL", IsString, "a string" );
    TestMandat( record, "AbstractHTML", IsString, "a string" );
    TestMandat( record, "PackageWWWHome", IsString, "a string" );
    if TestMandat( record, "PackageDoc",
           x -> IsRecord( x ) or IsRecordList( x ),
           "a record or a list of records" ) then
      if IsRecord( record.PackageDoc ) then
        list:= [ record.PackageDoc ];
      else
        list:= record.PackageDoc;
      fi;
      for subrec in list do
        TestMandat( subrec, "BookName", IsString, "a string" );
        if not IsBound(subrec.Archive) and not
                                   IsBound(subrec.ArchiveURLSubset) then
          Print("#E  PackageDoc component must have `Archive' or \
`ArchiveURLSubset' component\n");
          result := false;
        fi;
        TestOption( subrec, "Archive", IsString, "a string" );
        TestOption( subrec, "ArchiveURLSubset", IsStringList,
                    "a list of strings" );
        TestMandat( subrec, "HTMLStart", IsString, "a string" );
        TestMandat( subrec, "PDFFile", IsString, "a string" );
        TestMandat( subrec, "SixFile", IsString, "a string" );
        TestMandat( subrec, "LongTitle", IsString, "a string" );
      od;
    fi;
    if     TestOption( record, "Dependencies", IsRecord, "a record" )
       and IsBound( record.Dependencies ) then
      TestOption( record.Dependencies, "NeededOtherPackages",
          comp -> IsList( comp ) and ForAll( comp,
                      l -> IsList( l ) and Length( l ) = 2
                                       and ForAll( l, IsString ) ),
          "a list of pairs `[ <pkgname>, <pkgversion> ]' of strings" );
      TestOption( record.Dependencies, "SuggestedOtherPackages",
          comp -> IsList( comp ) and ForAll( comp,
                      l -> IsList( l ) and Length( l ) = 2
                                       and ForAll( l, IsString ) ),
          "a list of pairs `[ <pkgname>, <pkgversion> ]' of strings" );
      TestOption( record.Dependencies, "ExternalConditions",
          comp -> IsList( comp ) and ForAll( comp,
                      l -> IsString( l ) or ( IsList( l ) and Length( l ) = 2
                                      and ForAll( l, IsString ) ) ),
          "a list of strings or of pairs `[ <text>, <URL> ]' of strings" );

      # If the package is a needed package of GAP then all its needed
      # packages must also occur in the list of needed packages of GAP.
      list:= List( GAPInfo.Dependencies.NeededOtherPackages,
                   x -> LowercaseString( x[1] ) );
      if     IsBound( record.PackageName )
         and IsString( record.PackageName )
         and LowercaseString( record.PackageName ) in list
         and IsBound( record.Dependencies.NeededOtherPackages )
         and IsList( record.Dependencies.NeededOtherPackages ) then
        list:= Filtered( record.Dependencies.NeededOtherPackages,
                         x ->     IsList( x ) and IsBound( x[1] )
                              and IsString( x[1] )
                              and not LowercaseString( x[1] ) in list );
        if not IsEmpty( list ) then
          Print( "#E  the needed packages in '",
                 List( list, x -> x[1] ), "'\n",
                 "#E  are currently not needed packages of GAP\n" );
          result:= false;
        fi;
      fi;
    fi;
    TestMandat( record, "AvailabilityTest", IsFunction, "a function" );
    TestOption( record, "BannerString", IsString, "a string" );
    TestOption( record, "TestFile",
        x -> IsString( x ) and IsBound( x[1] ) and x[1] <> '/',
        "a string denoting a relative path" );
    TestOption( record, "PreloadFile", IsString, "a string" );
    TestOption( record, "Keywords", IsStringList, "a list of strings" );

    return result;
    end );


#############################################################################
##
#F  CheckPackageLoading( <pkgname> )
##
InstallGlobalFunction( CheckPackageLoading, function( pkgname )
    local result, oldinfo, i;

    result:= true;

    # Check that loading the package does not change info levels that were
    # defined before the package was loaded.
    oldinfo:= rec( CurrentLevels := ShallowCopy( InfoData.CurrentLevels ),
                   ClassNames := ShallowCopy( InfoData.ClassNames ) );
    LoadPackage( pkgname );
    for i in [ 1 .. Length( oldinfo.CurrentLevels ) ] do
      if oldinfo.CurrentLevels[i] <> InfoData.CurrentLevels[
             Position( InfoData.ClassNames, oldinfo.ClassNames[i] ) ] then
        Print( "#E  package `", pkgname, "' modifies info level of `",
               oldinfo.ClassNames[i], "'\n" );
        result:= false;
      fi;
    od;

    # Check the contents of the `PackageInfo.g' file of the package.
    Unbind( GAPInfo.PackageInfoCurrent );
    ReadPackage( pkgname, "PackageInfo.g" );
    if IsBound( GAPInfo.PackageInfoCurrent ) then
      result:= ValidatePackageInfo( GAPInfo.PackageInfoCurrent ) and result;
    else
      Print( "#E  missing or corrupted file `PackageInfo.g' for package `",
             pkgname, "'\n" );
      result:= false;
    fi;
    Unbind( GAPInfo.PackageInfoCurrent );

    return result;
    end );


#############################################################################
##
#V  GAPInfo.PackagesRestrictions
##
##  <ManSection>
##  <Var Name="GAPInfo.PackagesRestrictions"/>
##
##  <Description>
##  This is a mutable record, each component being the name of a package
##  <A>pkg</A> (in lowercase letters) that is required/recommended to be
##  updated to a certain version,
##  the value being a record with the following components.
##  <P/>
##  <List>
##  <Mark><C>OnInitialization</C></Mark>
##  <Item>
##      a function that takes one argument, the record stored in the
##      <F>PackageInfo.g</F> file of the package,
##      and returns <K>true</K> if the package can be loaded,
##      and returns <K>false</K> if not.
##      The function is allowed to change components of the argument record.
##      It should not print any message,
##      this should be left to the <C>OnLoad</C> component,
##  </Item>
##  <Mark><C>OnLoad</C></Mark>
##  <Item>
##      a function that takes one argument, the record stored in the
##      <F>PackageInfo.g</F> file of the package, and can print a message
##      when the availability of the package is checked for the first time;
##      this message is intended to explain why the package cannot loaded due
##      to the <K>false</K> result of the <C>OnInitialization</C> component,
##      or as a warning about known problems (when the package is in fact
##      loaded), and it might give hints for upgrading the package.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
GAPInfo.PackagesRestrictions := rec(
  anupq := rec(
    OnInitialization := function( pkginfo )
        if CompareVersionNumbers( pkginfo.Version, "1.3" ) = false then
          return false;
        fi;
        return true;
        end,
    OnLoad := function( pkginfo )
        if CompareVersionNumbers( pkginfo.Version, "1.3" ) = false then
          Print( "  The package `anupq'",
              " should better be upgraded at least to version 1.3,\n",
              "  the given version (", pkginfo.Version,
              ") is known to be incompatible\n",
              "  with the current version of GAP.\n",
              "  It is strongly recommended to update to the ",
              "most recent version, see URL\n",
              "      http://www.math.rwth-aachen.de/~Greg.Gamble/ANUPQ\n" );
        fi;
        end ),

  autpgrp := rec(
    OnInitialization := function( pkginfo )
        return true;
        end,
    OnLoad := function( pkginfo )
        if CompareVersionNumbers( pkginfo.Version, "1.1" ) = false then
          Print( "  The package `autpgrp'",
              " should better be upgraded at least to version 1.1,\n",
              "  the given version (", pkginfo.Version,
              ") is known to be incompatible\n",
              "  with the current version of GAP.\n",
              "  It is strongly recommended to update to the ",
              "most recent version, see URL\n",
              "      http://www-public.tu-bs.de:8080/~beick/so.html\n" );
        fi;
        end ) );


#############################################################################
##
#F  SuggestUpgrades( versions ) . . compare installed with distributed versions
##
InstallGlobalFunction( SuggestUpgrades, function( suggestedversions )
    local ok, outstr, out, entry, inform, info;

    suggestedversions := Set( List( suggestedversions, ShallowCopy ) );
    ok:= true;
    # We collect the output in a string, because availability test may
    # cause some intermediate printing. This way the output of the present
    # function comes after such texts.
    outstr := "";
    out := OutputTextString(outstr, true);
    PrintTo(out, "#I ======================================================",
                 "================ #\n",
                 "#I      Result of 'SuggestUpgrades':\n#I\n"
                 );
    # Deal with the kernel and library versions.
    entry:= First( suggestedversions, x -> x[1] = "GAPLibrary" );
    if entry = fail then
      PrintTo(out,  "#E  no info about suggested GAP library version ...\n" );
      ok:= false;
    elif not CompareVersionNumbers( GAPInfo.Version, entry[2] ) then
      PrintTo(out,  "#E  You are using version ", GAPInfo.Version,
             " of the GAP library.\n",
             "#E  Please upgrade to version ", entry[2], ".\n\n" );
      ok:= false;
    elif not CompareVersionNumbers( entry[2], GAPInfo.Version ) then
      PrintTo(out,  "#E  You are using version ", GAPInfo.Version,
             " of the GAP library.\n",
             "#E  This is newer than the distributed version ",
             entry[2], ".\n\n" );
      ok:= false;
    fi;
    RemoveSet( suggestedversions, entry );

    entry:= First( suggestedversions, x -> x[1] = "GAPKernel" );
    if entry = fail then
      PrintTo(out,  "#E  no info about suggested GAP kernel version ...\n" );
      ok:= false;
    elif not CompareVersionNumbers( GAPInfo.KernelVersion, entry[2] ) then
      PrintTo(out,  "#E  You are using version ", GAPInfo.KernelVersion,
             " of the GAP kernel.\n",
             "#E  Please upgrade to version ", entry[2], ".\n\n" );
      ok:= false;
    elif not CompareVersionNumbers( entry[2], GAPInfo.KernelVersion ) then
      PrintTo(out,  "#E  You are using version ", GAPInfo.KernelVersion,
             " of the GAP kernel.\n",
             "#E  This is newer than the distributed version ",
             entry[2], ".\n\n" );
      ok:= false;
    fi;
    RemoveSet( suggestedversions, entry );

    # Deal with present packages which are not distributed.
    inform := Difference(NamesOfComponents(GAPInfo.PackagesInfo),
              List(suggestedversions, x-> LowercaseString(x[1])));
    if not IsEmpty( inform ) then
      PrintTo(out,  "#I  The following GAP packages are present but not ",
                    "officially distributed.\n" );
      for entry in inform do
        info := GAPInfo.PackagesInfo.(entry)[1];
        PrintTo(out,  "#I    ", info.PackageName, " ", info.Version, "\n" );
      od;
      PrintTo(out,  "\n" );
      ok:= false;
    fi;


    # Deal with packages that are not installed.
    inform := Filtered( suggestedversions, entry -> not IsBound(
                   GAPInfo.PackagesInfo.( LowercaseString( entry[1] ) ) )
                 and ForAll( GAPInfo.PackagesInfoRefuseLoad,
                             r -> LowercaseString( entry[1] )
                                  <> LowercaseString( r.PackageName ) ) );
    if not IsEmpty( inform ) then
      PrintTo(out,  "#I  The following distributed GAP packages are ",
                    "not installed.\n" );
      for entry in inform do
        PrintTo(out,  "#I    ", entry[1], " ", entry[2], "\n" );
      od;
      PrintTo(out,  "\n" );
      ok:= false;
    fi;
    SubtractSet( suggestedversions, inform );

    # Deal with packages whose installed versions are not available
    # (without saying anything about the reason).
#T Here it would be desirable to omit those packages that cannot be loaded
#T on the current platform; e.g., Windoofs users need not be informed about
#T packages for which no Windoofs version is available.
    # These packages can be up to date or outdated.
    for entry in suggestedversions do
      Add( entry, InstalledPackageVersion( entry[1] ) );
#T Here we may get print statements from the availability testers;
#T how to avoid this?
    od;
    inform:= Filtered( suggestedversions, entry -> entry[3] = fail );
    if not IsEmpty( inform ) then
      PrintTo(out,  "#I  The following GAP packages are present ",
             "but cannot be used.\n" );
      for entry in inform do
        PrintTo(out,  "#I    ", entry[1], " ",
             GAPInfo.PackagesInfo.( LowercaseString( entry[1] ) )[1].Version,
             "\n" );
        if not ForAny( GAPInfo.PackagesInfo.( LowercaseString( entry[1] ) ),
                   r -> CompareVersionNumbers( r.Version, entry[2] ) ) then
          PrintTo(out,  "#I         (distributed version is newer:   ",
                   entry[2], ")\n" );
        fi;
      od;
      PrintTo(out, "\n" );
      ok:= false;
    fi;
    SubtractSet( suggestedversions, inform );

    # Deal with packages in *newer* (say, dev-) versions than the
    # distributed ones.
    inform:= Filtered( suggestedversions, entry -> not CompareVersionNumbers(
                 entry[2], entry[3] ) );
    if not IsEmpty( inform ) then
      PrintTo(out,
             "#I  Your following GAP packages are *newer* than the ",
             "distributed version.\n" );
      for entry in inform do
        PrintTo(out,  "#I    ", entry[1], " ", entry[3],
               " (distributed is ", entry[2], ")\n" );
      od;
      PrintTo(out,  "\n" );
      ok:= false;
    fi;
    # Deal with packages whose installed versions are not up to date.
    inform:= Filtered( suggestedversions, entry -> not CompareVersionNumbers(
                 entry[3], entry[2] ) );
    if not IsEmpty( inform ) then
      PrintTo(out,
             "#I  The following GAP packages are available but outdated.\n" );
      for entry in inform do
        PrintTo(out,  "#I    ", entry[1], " ", entry[3],
               " (please upgrade to ", entry[2], ")\n" );
      od;
      PrintTo(out,  "\n" );
      ok:= false;
    fi;

    if ok then
      PrintTo(out,  "#I  Your GAP installation is up to date with the ",
      "official distribution.\n\n" );
    fi;
    CloseStream(out);
    Print( outstr );
    end );


#############################################################################
##
#F  BibEntry( "GAP"[, <key>] )
#F  BibEntry( <pkgname>[, <key>] )
#F  BibEntry( <pkginfo>[, <key>] )
##
NormalizedNameAndKey:= "dummy";
RepeatedString:= "dummy";
FormatParagraph:= "dummy";
Unicode:= "dummy";
Encode:= "dummy";

InstallGlobalFunction( BibEntry, function( arg )
    local key, pkgname, pkginfo, GAP, ps, months, val, entry, author;

    if LoadPackage( "GAPDoc" ) <> true then
      return fail;
    fi;

    key:= false;
    if   Length( arg ) = 1 and IsString( arg[1] ) then
      pkgname:= arg[1];
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsString( arg[2] ) then
      pkgname:= arg[1];
      key:= arg[2];
    elif Length( arg ) = 1 and IsRecord( arg[1] ) then
      pkginfo:= arg[1];
    elif Length( arg ) = 2 and IsRecord( arg[1] ) and IsString( arg[2] ) then
      pkginfo:= arg[1];
      key:= arg[2];
    else
      Error( "usage: BibEntry( \"GAP\"[, <key>] ), ",
             "BibEntry( <pkgname>[, <key>] ), ",
             "BibEntry( <pkginfo>[, <key>] )" );
    fi;

    GAP:= false;
    if IsBound( pkgname ) then
      if pkgname = "GAP" then
        GAP:= true;
      else
        pkginfo:= PackageInfo( pkgname );
        if pkginfo = [] then
          return "";
        fi;
        pkginfo:= pkginfo[1];
      fi;
    fi;

    if key = false then
      if GAP then
        key:= Concatenation( "GAP", GAPInfo.Version );
      elif IsBound( pkginfo.Version ) then
        key:= Concatenation( pkginfo.PackageName, pkginfo.Version );
      else
        key:= pkginfo.PackageName;
      fi;
    fi;

    ps:= function( str )
      local uni;

      uni:= Unicode( str, "UTF-8" );
      if uni = fail then
        uni:= Unicode( str, "ISO-8859-1" );
      fi;
      return Encode( uni, GAPInfo.TermEncoding );
    end;

    # According to <Cite Key="La85"/>,
    # the supported fields of a Bib&TeX; entry of <C>@misc</C> type are
    # the following.
    # <P/>
    # <List>
    # <Mark><C>author</C></Mark>
    # <Item>
    #   computed from the <C>Persons</C> component of the package,
    #   not distinguishing authors and maintainers,
    #   keeping the ordering of entries,
    # </Item>
    # <Mark><C>title</C></Mark>
    # <Item>
    #   computed from the <C>PackageName</C> and <C>Subtitle</C> components
    #   of the package,
    # </Item>
    # <Mark><C>month</C> and <C>year</C></Mark>
    # <Item>
    #   computed from the <C>Date</C> component of the package,
    # </Item>
    # <Mark><C>note</C></Mark>
    # <Item>
    #   the string <C>"Refereed \\textsf{GAP} package"</C> or
    #   <C>"\\textsf{GAP} package"</C>,
    # </Item>
    # <Mark><C>howpublished</C></Mark>
    # <Item>
    #   the <C>PackageWWWHome</C> component of the package.
    # </Item>
    # </List>
    # <P/>
    # Also the <C>edition</C> component seems to be supported;
    # it is computed from the <C>Version</C> component of the package.

    # Bib&Tex;'s <C>@manual</C> type seems to be not appropriate,
    # since this type does not support a URL component
    # in the base bib styles of La&TeX;.
    # Instead we can use the <C>@misc</C> type and its <C>howpublished</C>
    # component.
    # We put the version information into the <C>title</C> component since
    # the <C>edition</C> component is not supported in the base styles.

    months:= [ "Jan", "Feb", "Mar", "Apr", "May", "Jun",
               "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];
    if GAP then
      val:= SplitString( GAPInfo.Date, "-" );
      if Length( val ) = 3 then
        if Int( val[2] ) in [ 1 .. 12 ] then
          val:= Concatenation( "  <month>", months[ Int( val[2] ) ],
                               "</month>\n  <year>", val[3], "</year>\n" );
        else
          val:= Concatenation( "  <month>", val[2],
                               "</month>\n  <year>", val[3], "</year>\n" );
        fi;
      else
        val:= "";
      fi;
      entry:= Concatenation(
        "<entry id=\"", key, "\"><misc>\n",
        "  <title><C>GAP</C> &ndash;",
        " <C>G</C>roups, <C>A</C>lgorithms,\n",
        "         and <C>P</C>rogramming,",
        " <C>V</C>ersion ", GAPInfo.Version, "</title>\n",
        "  <howpublished><URL>http://www.gap-system.org</URL></howpublished>\n",
        val,
        "  <key>GAP</key>\n",
        "  <keywords>groups; *; gap; manual</keywords>\n",
        "  <other type=\"organization\">The GAP <C>G</C>roup</other>\n",
        "</misc></entry>" );
    else
      entry:= Concatenation( "<entry id=\"", key, "\"><misc>\n" );
      author:= List( Filtered( pkginfo.Persons,
        person -> person.IsAuthor or person.IsMaintainer ),
          person -> Concatenation(
            "    <name><first>", person.FirstNames,
            "</first><last>", person.LastName, "</last></name>\n" ) );
      if not IsEmpty( author ) then
        Append( entry, Concatenation(
          "  <author>\n",
          ps( Concatenation( author ) ),
          "  </author>\n" ) );
      fi;
      Append( entry, Concatenation(
        "  <title><C>", pkginfo.PackageName, "</C>" ) );
      if IsBound( pkginfo.Subtitle ) then
        Append( entry, Concatenation(
          ", ", ps( pkginfo.Subtitle ) ) );
      fi;
      if IsBound( pkginfo.Version ) then
        Append( entry, Concatenation(
          ",\n         <C>V</C>ersion ", pkginfo.Version ) );
      fi;
      Append( entry, "</title>\n" );
      if IsBound( pkginfo.PackageWWWHome ) then
        Append( entry, Concatenation(
          "  <howpublished><URL>", pkginfo.PackageWWWHome,
          "</URL></howpublished>\n" ) );
      fi;
      if IsBound( pkginfo.Date ) and IsDenseList( pkginfo.Date )
                                 and Length( pkginfo.Date ) = 10 then
        if Int( pkginfo.Date{ [ 4, 5 ] } ) in [ 1 .. 12 ] then
          Append( entry, Concatenation(
            "  <month>", months[ Int( pkginfo.Date{ [ 4, 5 ] } ) ],
            "</month>\n",
            "  <year>", pkginfo.Date{ [ 7 .. 10 ] }, "</year>\n" ) );
        else
          Append( entry, Concatenation(
            "  <month>", pkginfo.Date{ [ 4, 5 ] }, "</month>\n",
            "  <year>", pkginfo.Date{ [ 7 .. 10 ] }, "</year>\n" ) );
        fi;
      fi;
      if IsBound( pkginfo.Status ) and pkginfo.Status = "accepted" then
        Append( entry, "  <note>Refereed GAP package</note>\n" );
      else
        Append( entry, "  <note>GAP package</note>\n" );
      fi;
      if IsBound( pkginfo.Keywords ) then
        Append( entry, Concatenation(
          "  <keywords>",
          JoinStringsWithSeparator( pkginfo.Keywords, "; " ),
          "</keywords>\n" ) );
      fi;
      Append( entry, "</misc></entry>" );
    fi;

    return entry;
end );

Unbind( NormalizedNameAndKey );
Unbind( RepeatedString );
Unbind( FormatParagraph );
Unbind( Unicode );
Unbind( Encode );

#############################################################################
##
#F  PackageVariablesInfo( <pkgname>[, <version>] )
##
NamesSystemGVars := "dummy";   # is not yet defined when this file is read
NamesUserGVars   := "dummy";

InstallGlobalFunction( PackageVariablesInfo, function( arg )
    local pkgname, version, test, info, banner, outercalls, name, pair,
          user_vars_orig, new, new_up_to_case, redeclared, newmethod, rules,
          data, rule, loaded, pkg, args, docmark, done, result, subrule,
          added, prev, subresult, entry, isrelevantvarname, globals,
          protected;

    # Get and check the arguments.
    if   Length( arg ) = 1 and IsString( arg[1] ) then
      pkgname:= LowercaseString( arg[1] );
      version:= "";
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsString( arg[2] ) then
      pkgname:= LowercaseString( arg[1] );
      version:= arg[2];
    else
      Error( "usage: ShowPackageVariables( <pkgname>[ <version>] )" );
    fi;

    # Check that the package is available but not yet loaded.
    test:= TestPackageAvailability( pkgname, version );
    if test = true then
      Print( "#E  the package `", pkgname, "' is already loaded\n" );
      return [];
    elif test = fail then
      Print( "#E  the package `", pkgname, "' cannot be loaded" );
      if version <> "" then
        Print( " in version `", version, "'" );
      fi;
      Print( "\n" );
      return [];
    fi;

    # Note that we want to list only variables defined in the package
    # `pkgname' but not in the required or suggested packages.
    # So we first load these packages but *not* `pkgname'.
    # Actually only the declaration part of these packages is loaded,
    # since the implementation part may rely on variables that are declared
    # in the declaration part of `pkgname'.
    info:= First( GAPInfo.PackagesInfo.( pkgname ),
        r -> IsBound( r.InstallationPath ) and r.InstallationPath = test );
    banner:= not GAPInfo.CommandLineOptions.q and
             not GAPInfo.CommandLineOptions.b;
    outercalls:= [ pkgname ];
    if IsBound( info.Dependencies ) then
      for name in [ "NeededOtherPackages", "SuggestedOtherPackages" ] do
        if IsBound( info.Dependencies.( name ) ) then
          for pair in info.Dependencies.( name ) do
            LoadPackage( pair[1], pair[2], banner, outercalls );
          od;
        fi;
      od;
    fi;

    # Store the current list of global variables.
    user_vars_orig:= Union( NamesSystemGVars(), NamesUserGVars() );
    new:= function( entry )
        if entry[1] in user_vars_orig then
          return fail;
        else
          return [ entry[1], ValueGlobal( entry[1] ) ];
        fi;
      end;

    new_up_to_case:= function( entry )
        if   entry[1] in user_vars_orig then
          return fail;
        elif LowercaseString( entry[1] ) in GAPInfo.data.lowercase_vars then
          return [ entry[1], ValueGlobal( entry[1] ) ];
        else
          Add( GAPInfo.data.lowercase_vars, LowercaseString( entry[1] ) );
          return fail;
        fi;
      end;

    redeclared:= function( entry )
        if entry[1] in user_vars_orig then
          return [ entry[1], ValueGlobal( entry[1] ) ];
        else
          return fail;
        fi;
      end;

    newmethod:= function( entry )
      local setter;

      if IsString( entry[2] ) and entry[2] in
             [ "system setter", "default method, does nothing" ] then
        setter:= entry[1];
        if ForAny( ATTRIBUTES, entry -> IsIdenticalObj( setter,
                                            Setter( entry[3] ) ) ) then
          return fail;
        fi;
      fi;
      return [ NameFunction( entry[1] ), entry[ Length( entry ) ] ];
      end;

    # List the cases to be dealt with.
    rules:= [
      [ "DeclareGlobalFunction",
        [ "new global functions", new ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareGlobalVariable",
        [ "new global variables", new ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareOperation",
        [ "new operations", new ],
        [ "redeclared operations", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareAttribute",
        [ "new attributes", new ],
        [ "redeclared attributes", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareProperty",
        [ "new properties", new ],
        [ "redeclared properties", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareCategory",
        [ "new categories", new ],
        [ "redeclared categories", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareRepresentation",
        [ "new representations", new ],
        [ "redeclared representations", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareFilter",
        [ "new plain filters", new ],
        [ "redeclared plain filters", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "InstallMethod",
        [ "new methods", newmethod ] ],
      [ "InstallOtherMethod",
        [ "new other methods", newmethod ] ],
      [ "DeclareSynonymAttr",
        [ "new synonyms of attributes", new ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareSynonym",
        [ "new synonyms", new ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      ];

    # Save the relevant global variables, and replace them.
    GAPInfo.data:= rec();
    GAPInfo.data.lowercase_vars:= List( user_vars_orig, LowercaseString );
    for rule in rules do
      GAPInfo.data.( rule[1] ):= [ ValueGlobal( rule[1] ), [] ];
      MakeReadWriteGlobal( rule[1] );
      UnbindGlobal( rule[1] );
      BindGlobal( rule[1], EvalString( Concatenation(
          "function( arg ) ",
          "Add( GAPInfo.data.( \"", rule[1], "\" )[2], arg ); ",
          "CallFuncList( GAPInfo.data.( \"", rule[1], "\" )[1], arg ); ",
          "end" ) ) );

    od;

    # Load the package `pkgname', under the assumption that the
    # needed/suggested packages are already loaded).
    loaded:= LoadPackage( pkgname );

    # Put the original global variables back.
    for rule in rules do
      MakeReadWriteGlobal( rule[1] );
      UnbindGlobal( rule[1] );
      BindGlobal( rule[1], GAPInfo.data.( rule[1] )[1] );
    od;

    if not loaded then
      Print( "#E  the package `", pkgname, "' could not be loaded\n" );
      return [];
    fi;

    # Store the list of globals available before the implementation part
    # of the needed/suggested packages is read.
    globals:= Difference( NamesUserGVars(), user_vars_orig );

    # Read the implementation part of the needed/suggested packages.
    outercalls:= Reversed( outercalls );
    Unbind( outercalls[ Length( outercalls ) ] );
    for pkg in outercalls do
      ReadPackage( pkg, "read.g" );
    od;

    # Functions are printed via their lists of arguments.
    args:= function( func )
      local num, nam, str;

      if not IsFunction( func ) then
        return "";
      fi;
      num:= NumberArgumentsFunction( func );
      nam:= NamesLocalVariablesFunction( func );
      if num = -1 then
        str:= "arg";
      elif nam = fail then
        str:= "...";
      else
        str:= JoinStringsWithSeparator( nam{ [ 1 .. num ] }, ", " );
      fi;
      return Concatenation( "( ", str, " )" );
    end;

    # Mark undocumented globals with an asterisk.
    docmark:= function( varname )
      if not ( IsBoundGlobal( varname ) and IsDocumentedWord( varname ) ) then
        return "*";
      else
        return "";
      fi;
    end;

    # Prepare the output.
    done:= [];
    result:= [];
    for rule in rules do
      for subrule in rule{ [ 2 .. Length( rule ) ] } do
        added:= Filtered( List( GAPInfo.data.( rule[1] )[2], subrule[2] ),
                          x -> x <> fail );
        prev:= First( result, x -> x[1] = subrule[1] );
        if prev = fail then
          Add( result, [ subrule[1], added ] );
        else
          Append( prev[2], added );
        fi;
      od;
    od;
    for subresult in result do
      if IsEmpty( subresult[2] ) then
        subresult[1]:= Concatenation( "no ", subresult[1] );
      else
        subresult[1]:= Concatenation( subresult[1], ":" );
        added:= subresult[2];
        subresult[2]:= [];
        Sort( added, function( a, b ) return a[1] < b[1]; end );
        for entry in added do
          Add( subresult[2], [ "  ", entry[1], args( entry[2] ),
                               docmark( entry[1] ) ] );
          AddSet( done, entry[1] );
        od;
      fi;
    od;
    Unbind( GAPInfo.data );

    # Mention the remaining new globals.
    # (Omit `Set<attr>' and `Has<attr>' type variables.)
    isrelevantvarname:= function( name )
      local attr;

      if Length( name ) <= 3
         or not ( name{ [ 1 .. 3 ] } in [ "Has", "Set" ] ) then
        return true;
      fi;
      name:= name{ [ 4 .. Length( name ) ] };
      if not IsBoundGlobal( name ) then
        return true;
      fi;
      attr:= ValueGlobal( name );
      if ForAny( ATTRIBUTES, entry -> IsIdenticalObj( attr, entry[3] ) ) then
        return false;
      fi;
      return true;
    end;

    added:= Filtered( Difference( globals, done ), isrelevantvarname );
    protected:= Filtered( added, IsReadOnlyGVar );
    if not IsEmpty( protected ) then
      subresult:= [ "other new globals (write protected):", [] ];
      for entry in SortedList( protected ) do
        Add( subresult[2], [ "  ", entry, args( ValueGlobal( entry ) ),
                             docmark( entry ) ] );
      od;
      Add( result, subresult );
    fi;
    added:= Difference( added, protected );
    if not IsEmpty( added ) then
      subresult:= [ "other new globals (not write protected):", [] ];
      for entry in SortedList( added ) do
        Add( subresult[2], [ "  ", entry, args( ValueGlobal( entry ) ),
                             docmark( entry ) ] );
      od;
      Add( result, subresult );
    fi;

    return result;
    end );

Unbind( NamesSystemGVars );
Unbind( NamesUserGVars );


#############################################################################
##
#F  ShowPackageVariables( <pkgname>[, <version>] )
##
InstallGlobalFunction( ShowPackageVariables, function( arg )
    local entry, subentry;

    for entry in CallFuncList( PackageVariablesInfo, arg ) do
      Print( entry[1], "\n" );
      for subentry in entry[2] do
        Print( Concatenation( subentry ), "\n" );
      od;
      Print( "\n" );
    od;
    end );


#############################################################################
##
#E


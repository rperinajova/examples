!> \file
!> $Id: LidDrivenCavity.f90
!> \author David Ladd
!> \brief This is an example program to solve a static lid driven cavity problem using OpenCMISS calls.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is OpenCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand and University of Oxford, Oxford, United
!> Kingdom. Portions created by the University of Auckland and University
!> of Oxford are Copyright (C) 2007 by the University of Auckland and
!> the University of Oxford. All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!> \example FluidMechanics/NavierStokes/RoutineCheck/Static/src/LidDrivenCavityExample.f90
!! Example program to solve a benchmark Lid-driven cavity problem using OpenCMISS calls.
!! \htmlinclude FluidMechanics/NavierStokes/LidDrivenCavity/history.html
!!
!<

!> Main program

PROGRAM LIDDRIVENCAVITY

  !
  !================================================================================================================================
  !

  !PROGRAM LIBRARIES

  USE OPENCMISS
  USE FLUID_MECHANICS_IO_ROUTINES
  USE FIELDML_API
  USE MPI


#ifdef WIN32
  USE IFQWINCMISS
#endif

  !
  !================================================================================================================================
  !

  !PROGRAM VARIABLES AND TYPES

  IMPLICIT NONE

  INTEGER(CMISSIntg), PARAMETER :: EquationsSetFieldUserNumber=1337
  TYPE(CMISSFieldType) :: EquationsSetField


  !Test program parameters

  INTEGER(CMISSIntg), PARAMETER :: CoordinateSystemUserNumber=1
  INTEGER(CMISSIntg), PARAMETER :: RegionUserNumber=2
  INTEGER(CMISSIntg), PARAMETER :: MeshUserNumber=3
  INTEGER(CMISSIntg), PARAMETER :: DecompositionUserNumber=4
  INTEGER(CMISSIntg), PARAMETER :: GeometricFieldUserNumber=5
  INTEGER(CMISSIntg), PARAMETER :: DependentFieldUserNumberNavierStokes=6
  INTEGER(CMISSIntg), PARAMETER :: MaterialsFieldUserNumberNavierStokes=7
  INTEGER(CMISSIntg), PARAMETER :: IndependentFieldUserNumberNavierStokes=8
  INTEGER(CMISSIntg), PARAMETER :: EquationsSetUserNumberNavierStokes=9
  INTEGER(CMISSIntg), PARAMETER :: ProblemUserNumber=10

  INTEGER(CMISSIntg), PARAMETER :: DomainUserNumber=2
  INTEGER(CMISSIntg), PARAMETER :: SolverNavierStokesUserNumber=1
  INTEGER(CMISSIntg), PARAMETER :: MaterialsFieldUserNumberNavierStokesMu=1
  INTEGER(CMISSIntg), PARAMETER :: MaterialsFieldUserNumberNavierStokesRho=2

  INTEGER(CMISSIntg), PARAMETER :: EquationsSetFieldUserNumberNavierStokesH=1
  INTEGER(CMISSIntg), PARAMETER :: EquationsSetFieldUserNumberNavierStokesUMAX=2
  INTEGER(CMISSIntg), PARAMETER :: EquationsSetFieldUserNumberNavierStokesRE=3
  INTEGER(CMISSIntg), PARAMETER :: EquationsSetFieldUserNumberNavierStokesC=4


  !Program types

  TYPE(EXPORT_CONTAINER):: CM

  !Program variables

  INTEGER(CMISSIntg) :: NUMBER_OF_DIMENSIONS
  
  INTEGER(CMISSIntg) :: BASIS_TYPE
  INTEGER(CMISSIntg) :: BASIS_NUMBER_SPACE
  INTEGER(CMISSIntg) :: BASIS_NUMBER_VELOCITY
  INTEGER(CMISSIntg) :: BASIS_NUMBER_PRESSURE
  INTEGER(CMISSIntg) :: BASIS_XI_GAUSS_SPACE
  INTEGER(CMISSIntg) :: BASIS_XI_GAUSS_VELOCITY
  INTEGER(CMISSIntg) :: BASIS_XI_GAUSS_PRESSURE
  INTEGER(CMISSIntg) :: BASIS_XI_INTERPOLATION_SPACE
  INTEGER(CMISSIntg) :: BASIS_XI_INTERPOLATION_VELOCITY
  INTEGER(CMISSIntg) :: BASIS_XI_INTERPOLATION_PRESSURE
  INTEGER(CMISSIntg) :: MESH_NUMBER_OF_COMPONENTS
  INTEGER(CMISSIntg) :: MESH_COMPONENT_NUMBER_SPACE
  INTEGER(CMISSIntg) :: MESH_COMPONENT_NUMBER_VELOCITY
  INTEGER(CMISSIntg) :: MESH_COMPONENT_NUMBER_PRESSURE
  INTEGER(CMISSIntg) :: NUMBER_OF_NODES_SPACE
  INTEGER(CMISSIntg) :: NUMBER_OF_NODES_VELOCITY
  INTEGER(CMISSIntg) :: NUMBER_OF_NODES_PRESSURE
  INTEGER(CMISSIntg) :: NUMBER_OF_ELEMENT_NODES_SPACE
  INTEGER(CMISSIntg) :: NUMBER_OF_ELEMENT_NODES_VELOCITY
  INTEGER(CMISSIntg) :: NUMBER_OF_ELEMENT_NODES_PRESSURE
  INTEGER(CMISSIntg) :: TOTAL_NUMBER_OF_NODES
  INTEGER(CMISSIntg) :: TOTAL_NUMBER_OF_ELEMENTS
  INTEGER(CMISSIntg) :: MAXIMUM_ITERATIONS
  INTEGER(CMISSIntg) :: RESTART_VALUE
!   INTEGER(CMISSIntg) :: MPI_IERROR
  INTEGER(CMISSIntg) :: NUMBER_OF_FIXED_WALL_NODES_NAVIER_STOKES
  INTEGER(CMISSIntg) :: NUMBER_OF_LID_NODES_NAVIER_STOKES

  INTEGER(CMISSIntg) :: I
  INTEGER(CMISSIntg) :: ANALYTIC_TYPE

  INTEGER(CMISSIntg) :: EQUATIONS_NAVIER_STOKES_OUTPUT
  INTEGER(CMISSIntg) :: COMPONENT_NUMBER
  INTEGER(CMISSIntg) :: NODE_NUMBER
  INTEGER(CMISSIntg) :: ELEMENT_NUMBER
  INTEGER(CMISSIntg) :: NODE_COUNTER
  INTEGER(CMISSIntg) :: CONDITION

  INTEGER, ALLOCATABLE, DIMENSION(:):: FIXED_WALL_NODES_NAVIER_STOKES
  INTEGER, ALLOCATABLE, DIMENSION(:):: LID_NODES_NAVIER_STOKES


  INTEGER(CMISSIntg) :: DYNAMIC_SOLVER_NAVIER_STOKES_OUTPUT_FREQUENCY
  INTEGER(CMISSIntg) :: DYNAMIC_SOLVER_NAVIER_STOKES_OUTPUT_TYPE
  INTEGER(CMISSIntg) :: NONLINEAR_SOLVER_NAVIER_STOKES_OUTPUT_TYPE
  INTEGER(CMISSIntg) :: LINEAR_SOLVER_NAVIER_STOKES_OUTPUT_TYPE

  INTEGER(CMISSIntg) :: EquationsSetSubtype
  INTEGER(CMISSIntg) :: ProblemSubtype

  REAL(CMISSDP) :: INITIAL_FIELD_NAVIER_STOKES(2)
  REAL(CMISSDP) :: BOUNDARY_CONDITIONS_NAVIER_STOKES(2)
  REAL(CMISSDP) :: DIVERGENCE_TOLERANCE
  REAL(CMISSDP) :: RELATIVE_TOLERANCE
  REAL(CMISSDP) :: ABSOLUTE_TOLERANCE
  REAL(CMISSDP) :: LINESEARCH_ALPHA
  REAL(CMISSDP) :: VALUE
  REAL(CMISSDP) :: MU_PARAM_NAVIER_STOKES
  REAL(CMISSDP) :: RHO_PARAM_NAVIER_STOKES
  REAL(CMISSDP) :: H_PARAM
  REAL(CMISSDP) :: UMAX_PARAM
  REAL(CMISSDP) :: RE_PARAM
  REAL(CMISSDP) :: C_PARAM

  REAL(CMISSDP) :: DYNAMIC_SOLVER_NAVIER_STOKES_START_TIME
  REAL(CMISSDP) :: DYNAMIC_SOLVER_NAVIER_STOKES_STOP_TIME
  REAL(CMISSDP) :: DYNAMIC_SOLVER_NAVIER_STOKES_THETA
  REAL(CMISSDP) :: DYNAMIC_SOLVER_NAVIER_STOKES_TIME_INCREMENT

  LOGICAL :: EXPORT_FIELD_IO
  LOGICAL :: LINEAR_SOLVER_NAVIER_STOKES_DIRECT_FLAG
  LOGICAL :: FIXED_WALL_NODES_NAVIER_STOKES_FLAG
  LOGICAL :: LID_NODES_NAVIER_STOKES_FLAG
  LOGICAL :: SUPG_FLAG
  LOGICAL :: ALE_SOLVER_NAVIER_STOKES_FLAG
  LOGICAL :: ANALYTIC_FLAG
  LOGICAL :: DYNAMIC_SOLVER_NAVIER_STOKES_FLAG
  LOGICAL :: DYNAMIC_SOLVER_NAVIER_STOKES_RESUME_SOLVE_FLAG

!  LOGICAL :: ElementExists

  CHARACTER *15 BUFFER
  CHARACTER *15 ARG
  CHARACTER *15 OUTPUT_STRING

  !CMISS variables

  !Regions
  TYPE(CMISSRegionType) :: Region
  TYPE(CMISSRegionType) :: WorldRegion
  !Coordinate systems
  TYPE(CMISSCoordinateSystemType) :: CoordinateSystem
  TYPE(CMISSCoordinateSystemType) :: WorldCoordinateSystem
  !Basis
  TYPE(CMISSBasisType) :: BasisSpace
  TYPE(CMISSBasisType) :: BasisVelocity
  TYPE(CMISSBasisType) :: BasisPressure
  !Nodes
  TYPE(CMISSNodesType) :: Nodes
  !Elements
  TYPE(CMISSMeshElementsType) :: MeshElementsSpace
  TYPE(CMISSMeshElementsType) :: MeshElementsVelocity
  TYPE(CMISSMeshElementsType) :: MeshElementsPressure
  !Meshes
  TYPE(CMISSMeshType) :: Mesh
  !Decompositions
  TYPE(CMISSDecompositionType) :: Decomposition
  !Fields
  TYPE(CMISSFieldsType) :: Fields
  !Field types
  TYPE(CMISSFieldType) :: GeometricField
  TYPE(CMISSFieldType) :: DependentFieldNavierStokes
  TYPE(CMISSFieldType) :: MaterialsFieldNavierStokes
  !Boundary conditions
  TYPE(CMISSBoundaryConditionsType) :: BoundaryConditionsNavierStokes
  !Equations sets
  TYPE(CMISSEquationsSetType) :: EquationsSetNavierStokes
  !Equations
  TYPE(CMISSEquationsType) :: EquationsNavierStokes
  !Problems
  TYPE(CMISSProblemType) :: Problem
  !Control loops
  TYPE(CMISSControlLoopType) :: ControlLoop
  !Solvers
  TYPE(CMISSSolverType) :: DynamicSolverNavierStokes
  TYPE(CMISSSolverType) :: NonlinearSolverNavierStokes
  TYPE(CMISSSolverType) :: LinearSolverNavierStokes
  !Solver equations
  TYPE(CMISSSolverEquationsType) :: SolverEquationsNavierStokes

  !FieldML parsing variables
  TYPE(CMISSFieldMLIOType) :: fieldmlInfo, outputInfo


#ifdef WIN32
  !Quickwin type
  LOGICAL :: QUICKWIN_STATUS=.FALSE.
  TYPE(WINDOWCONFIG) :: QUICKWIN_WINDOW_CONFIG
#endif
  
  !Generic CMISS variables

  INTEGER(CMISSIntg) :: NumberOfComputationalNodes,ComputationalNodeNumber,BoundaryNodeDomain
  INTEGER(CMISSIntg) :: ComputationalNode

  INTEGER(CMISSIntg) :: ElementsPerComputationalNode
  INTEGER(CMISSIntg) :: ElementsInComputationalNode
  INTEGER(CMISSIntg) :: EquationsSetIndex
  INTEGER(CMISSIntg) :: Err
  INTEGER(CMISSIntg) :: DEBUG_ElementComputationalNode(512)
  
#ifdef WIN32
  !Initialise QuickWin
  QUICKWIN_WINDOW_CONFIG%TITLE="General Output" !Window title
  QUICKWIN_WINDOW_CONFIG%NUMTEXTROWS=-1 !Max possible number of rows
  QUICKWIN_WINDOW_CONFIG%MODE=QWIN$SCROLLDOWN
  !Set the window parameters
  QUICKWIN_STATUS=SETWINDOWCONFIG(QUICKWIN_WINDOW_CONFIG)
  !If attempt fails set with system estimated values
  IF(.NOT.QUICKWIN_STATUS) QUICKWIN_STATUS=SETWINDOWCONFIG(QUICKWIN_WINDOW_CONFIG)
#endif

  !
  !================================================================================================================================
  !

  !INITIALISE OPENCMISS

  CALL CMISSInitialise(WorldCoordinateSystem,WorldRegion,Err)

  !
  !================================================================================================================================
  !

  !CHECK COMPUTATIONAL NODE

  !Get the computational nodes information
  CALL CMISSComputationalNumberOfNodesGet(NumberOfComputationalNodes,Err)
  CALL CMISSComputationalNodeNumberGet(ComputationalNodeNumber,Err)

  !
  !================================================================================================================================
  !

  !PROBLEM CONTROL PANEL

  !Import cmHeart mesh information
  CALL FLUID_MECHANICS_IO_READ_CMHEART(CM,Err)  
  BASIS_NUMBER_SPACE=CM%ID_M
  BASIS_NUMBER_VELOCITY=CM%ID_V
  BASIS_NUMBER_PRESSURE=CM%ID_P
  NUMBER_OF_DIMENSIONS=CM%D
  BASIS_TYPE=CM%IT_T
  BASIS_XI_INTERPOLATION_SPACE=CM%IT_M
  BASIS_XI_INTERPOLATION_VELOCITY=CM%IT_V
  BASIS_XI_INTERPOLATION_PRESSURE=CM%IT_P
  NUMBER_OF_NODES_SPACE=CM%N_M
  NUMBER_OF_NODES_VELOCITY=CM%N_V
  NUMBER_OF_NODES_PRESSURE=CM%N_P
  TOTAL_NUMBER_OF_NODES=CM%N_T
  TOTAL_NUMBER_OF_ELEMENTS=CM%E_T
  NUMBER_OF_ELEMENT_NODES_SPACE=CM%EN_M
  NUMBER_OF_ELEMENT_NODES_VELOCITY=CM%EN_V
  NUMBER_OF_ELEMENT_NODES_PRESSURE=CM%EN_P
  !Set initial values
  INITIAL_FIELD_NAVIER_STOKES(1)=0.0_CMISSDP
  INITIAL_FIELD_NAVIER_STOKES(2)=0.0_CMISSDP
  !Set boundary conditions
  BOUNDARY_CONDITIONS_NAVIER_STOKES(1)=1.0_CMISSDP
  BOUNDARY_CONDITIONS_NAVIER_STOKES(2)=0.0_CMISSDP
  FIXED_WALL_NODES_NAVIER_STOKES_FLAG=.TRUE.
  LID_NODES_NAVIER_STOKES_FLAG=.TRUE.
  DYNAMIC_SOLVER_NAVIER_STOKES_FLAG=.TRUE.
  !Initialize SUPG
  SUPG_FLAG=.TRUE.
  !Set material parameters
  MU_PARAM_NAVIER_STOKES=0.01_CMISSDP
  RHO_PARAM_NAVIER_STOKES=1.0_CMISSDP
  !Set interpolation parameters
  BASIS_XI_GAUSS_SPACE=2
  BASIS_XI_GAUSS_VELOCITY=2
  BASIS_XI_GAUSS_PRESSURE=2
  !Set output parameter
  !(NoOutput/ProgressOutput/TimingOutput/SolverOutput/SolverMatrixOutput)
  DYNAMIC_SOLVER_NAVIER_STOKES_OUTPUT_TYPE=CMISS_SOLVER_NO_OUTPUT
  LINEAR_SOLVER_NAVIER_STOKES_OUTPUT_TYPE=CMISS_SOLVER_NO_OUTPUT
  NONLINEAR_SOLVER_NAVIER_STOKES_OUTPUT_TYPE=CMISS_SOLVER_Progress_OUTPUT
  !(NoOutput/TimingOutput/MatrixOutput/ElementOutput)
  EQUATIONS_NAVIER_STOKES_OUTPUT=CMISS_EQUATIONS_NO_OUTPUT
  !Set time parameter
  DYNAMIC_SOLVER_NAVIER_STOKES_RESUME_SOLVE_FLAG=.FALSE.
  DYNAMIC_SOLVER_NAVIER_STOKES_START_TIME=0.0_CMISSDP
  DYNAMIC_SOLVER_NAVIER_STOKES_STOP_TIME=1.0_CMISSDP 
  DYNAMIC_SOLVER_NAVIER_STOKES_TIME_INCREMENT=0.01_CMISSDP
  DYNAMIC_SOLVER_NAVIER_STOKES_THETA=1.0_CMISSDP
  !Set result output parameter
  DYNAMIC_SOLVER_NAVIER_STOKES_OUTPUT_FREQUENCY=10
  !Set solver parameters
  LINEAR_SOLVER_NAVIER_STOKES_DIRECT_FLAG=.TRUE.
  RELATIVE_TOLERANCE=1.0E-5_CMISSDP !default: 1.0E-05_CMISSDP
  ABSOLUTE_TOLERANCE=1.0E-6_CMISSDP !default: 1.0E-10_CMISSDP
  DIVERGENCE_TOLERANCE=1.0E5 !default: 1.0E5
  MAXIMUM_ITERATIONS=100000 !default: 100000
  RESTART_VALUE=300 !default: 30
  LINESEARCH_ALPHA=1.0

  !Initialize other values
  ANALYTIC_FLAG=.FALSE.
  ALE_SOLVER_NAVIER_STOKES_FLAG=.FALSE.

  !Get command line arguments
  DO I=1,COMMAND_ARGUMENT_COUNT()
    CALL GET_COMMAND_ARGUMENT(I,ARG)
    SELECT CASE(ARG)
      CASE('-density')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) RHO_PARAM_NAVIER_STOKES
      CASE('-viscosity')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) MU_PARAM_NAVIER_STOKES
      CASE('-directsolver')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) LINEAR_SOLVER_NAVIER_STOKES_DIRECT_FLAG
      CASE('-dynamic')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) DYNAMIC_SOLVER_NAVIER_STOKES_FLAG
      CASE('-ALE')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) ALE_SOLVER_NAVIER_STOKES_FLAG
      CASE('-outfrequency')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) DYNAMIC_SOLVER_NAVIER_STOKES_OUTPUT_FREQUENCY
      CASE('-SUPG')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) SUPG_FLAG
      CASE('-analytic')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) ANALYTIC_FLAG
      CASE('-analytictype')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) ANALYTIC_TYPE
      CASE('-analyticoutput')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) OUTPUT_STRING
      CASE('-resume')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) DYNAMIC_SOLVER_NAVIER_STOKES_RESUME_SOLVE_FLAG
      CASE('-starttime')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) DYNAMIC_SOLVER_NAVIER_STOKES_START_TIME
      CASE('-stoptime')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) DYNAMIC_SOLVER_NAVIER_STOKES_STOP_TIME
      CASE('-timeincrement')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) DYNAMIC_SOLVER_NAVIER_STOKES_TIME_INCREMENT
      CASE('-velocity')
        CALL GET_COMMAND_ARGUMENT(I+1,BUFFER)
        READ(BUFFER,*) BOUNDARY_CONDITIONS_NAVIER_STOKES(1)
        CALL GET_COMMAND_ARGUMENT(I+2,BUFFER)
        READ(BUFFER,*) BOUNDARY_CONDITIONS_NAVIER_STOKES(2)
!        CALL GET_COMMAND_ARGUMENT(I+3,BUFFER)
!        READ(BUFFER,*) BOUNDARY_CONDITIONS_NAVIER_STOKES(3)
      CASE DEFAULT
        !do nothing
      END SELECT
  ENDDO 
  WRITE(*,*)' '
  WRITE(*,*)' ************************************* '
  WRITE(*,*)' '
  WRITE(*,*)'-density........', RHO_PARAM_NAVIER_STOKES
  WRITE(*,*)'-viscosity......', MU_PARAM_NAVIER_STOKES
  WRITE(*,*)'-analytic.......  ', ANALYTIC_FLAG
  WRITE(*,*)'-SUPG.......  ', SUPG_FLAG
  WRITE(*,*)'-velocity.......', BOUNDARY_CONDITIONS_NAVIER_STOKES
  WRITE(*,*)'-dynamic........  ', DYNAMIC_SOLVER_NAVIER_STOKES_FLAG
  IF(DYNAMIC_SOLVER_NAVIER_STOKES_FLAG) THEN
    WRITE(*,*) ' ' 
    WRITE(*,*)'  -resume............  ', DYNAMIC_SOLVER_NAVIER_STOKES_RESUME_SOLVE_FLAG
    WRITE(*,*)'  -starttime......  ', DYNAMIC_SOLVER_NAVIER_STOKES_START_TIME
    WRITE(*,*)'  -stoptime.......  ', DYNAMIC_SOLVER_NAVIER_STOKES_STOP_TIME
    WRITE(*,*)'  -timeincrement..  ', DYNAMIC_SOLVER_NAVIER_STOKES_TIME_INCREMENT
    WRITE(*,*)'  -outputfrequency..  ', DYNAMIC_SOLVER_NAVIER_STOKES_OUTPUT_FREQUENCY
    WRITE(*,*)'  -ALE............  ', ALE_SOLVER_NAVIER_STOKES_FLAG
    WRITE(*,*) ' ' 
  ENDIF
  WRITE(*,*)'-directsolver...  ', LINEAR_SOLVER_NAVIER_STOKES_DIRECT_FLAG
  WRITE(*,*)' '
  WRITE(*,*)' ************************************* '
  WRITE(*,*)' '
  WRITE(*,*) ' ' 
  !Set boundary conditions
  INQUIRE(FILE="./input/bc/FIXED_WALL", EXIST=FIXED_WALL_NODES_NAVIER_STOKES_FLAG)
  INQUIRE(FILE="./input/bc/LID", EXIST=LID_NODES_NAVIER_STOKES_FLAG)
!  INITIAL_FIELD_NAVIER_STOKES(1)=0.0_DP
!  INITIAL_FIELD_NAVIER_STOKES(2)=0.0_DP
!  INITIAL_FIELD_NAVIER_STOKES(3)=BOUNDARY_CONDITIONS_NAVIER_STOKES(3)
  IF(FIXED_WALL_NODES_NAVIER_STOKES_FLAG) THEN
    OPEN(UNIT=1, FILE="./input/bc/FIXED_WALL",STATUS='unknown')
    READ(1,*) NUMBER_OF_FIXED_WALL_NODES_NAVIER_STOKES
    ALLOCATE(FIXED_WALL_NODES_NAVIER_STOKES(NUMBER_OF_FIXED_WALL_NODES_NAVIER_STOKES))
    READ(1,*) FIXED_WALL_NODES_NAVIER_STOKES(1:NUMBER_OF_FIXED_WALL_NODES_NAVIER_STOKES)
    CLOSE(1)
  ENDIF
  IF(LID_NODES_NAVIER_STOKES_FLAG) THEN
     OPEN(UNIT=1, FILE="./input/bc/LID",STATUS='unknown')
    READ(1,*) NUMBER_OF_LID_NODES_NAVIER_STOKES
    ALLOCATE(LID_NODES_NAVIER_STOKES(NUMBER_OF_LID_NODES_NAVIER_STOKES))
    READ(1,*) LID_NODES_NAVIER_STOKES(1:NUMBER_OF_LID_NODES_NAVIER_STOKES)
    CLOSE(1)
  ENDIF
!  ADD_SUPG_PARAMETERS=.FALSE.
  IF(SUPG_FLAG) THEN
    EquationsSetSubtype=CMISS_Equations_Set_Transient_SUPG_Navier_Stokes_Subtype
    ProblemSubtype=CMISS_Problem_Transient_SUPG_Navier_Stokes_Subtype
!    ADD_SUPG_PARAMETERS=.TRUE.
  ELSE
    EquationsSetSubtype=CMISS_EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE
    ProblemSubtype=CMISS_PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE
  ENDIF
  !
  !================================================================================================================================
  !

  !COORDINATE SYSTEM

  !Start the creation of a new RC coordinate system
  CALL CMISSCoordinateSystem_Initialise(CoordinateSystem,Err)
  CALL CMISSCoordinateSystem_CreateStart(CoordinateSystemUserNumber,CoordinateSystem,Err)
  !Set the coordinate system dimension
  CALL CMISSCoordinateSystem_DimensionSet(CoordinateSystem,NUMBER_OF_DIMENSIONS,Err)
  !Finish the creation of the coordinate system
  CALL CMISSCoordinateSystem_CreateFinish(CoordinateSystem,Err)

  !
  !================================================================================================================================
  !

  !REGION

  !Start the creation of a new region
  CALL CMISSRegion_Initialise(Region,Err)
  CALL CMISSRegion_CreateStart(RegionUserNumber,WorldRegion,Region,Err)
  !Set the regions coordinate system as defined above
  CALL CMISSRegion_CoordinateSystemSet(Region,CoordinateSystem,Err)
  !Finish the creation of the region
  CALL CMISSRegion_CreateFinish(Region,Err)

  !
  !================================================================================================================================
  !

  !BASES

  !Start the creation of new bases
  MESH_NUMBER_OF_COMPONENTS=1
  CALL CMISSBasis_Initialise(BasisSpace,Err)
  CALL CMISSBasis_CreateStart(BASIS_NUMBER_SPACE,BasisSpace,Err)
  !Set the basis type (Lagrange/Simplex)
  CALL CMISSBasis_TypeSet(BasisSpace,BASIS_TYPE,Err)
  !Set the basis xi number
  CALL CMISSBasis_NumberOfXiSet(BasisSpace,NUMBER_OF_DIMENSIONS,Err)
  !Set the basis xi interpolation and number of Gauss points
  IF(NUMBER_OF_DIMENSIONS==2) THEN
    CALL CMISSBasis_InterpolationXiSet(BasisSpace,(/BASIS_XI_INTERPOLATION_SPACE,BASIS_XI_INTERPOLATION_SPACE/),Err)
    CALL CMISSBasis_QuadratureNumberOfGaussXiSet(BasisSpace,(/BASIS_XI_GAUSS_SPACE,BASIS_XI_GAUSS_SPACE/),Err)
  ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
    CALL CMISSBasis_InterpolationXiSet(BasisSpace,(/BASIS_XI_INTERPOLATION_SPACE,BASIS_XI_INTERPOLATION_SPACE, & 
      & BASIS_XI_INTERPOLATION_SPACE/),Err)                         
    CALL CMISSBasis_QuadratureNumberOfGaussXiSet(BasisSpace,(/BASIS_XI_GAUSS_SPACE,BASIS_XI_GAUSS_SPACE,BASIS_XI_GAUSS_SPACE/),Err)
  ENDIF
  !Finish the creation of the basis
  CALL CMISSBasis_CreateFinish(BasisSpace,Err)
  !Start the creation of another basis
  IF(BASIS_XI_INTERPOLATION_VELOCITY==BASIS_XI_INTERPOLATION_SPACE) THEN
    BasisVelocity=BasisSpace
  ELSE
    MESH_NUMBER_OF_COMPONENTS=MESH_NUMBER_OF_COMPONENTS+1
    !Initialise a new velocity basis
    CALL CMISSBasis_Initialise(BasisVelocity,Err)
    !Start the creation of a basis
    CALL CMISSBasis_CreateStart(BASIS_NUMBER_VELOCITY,BasisVelocity,Err)
    !Set the basis type (Lagrange/Simplex)
    CALL CMISSBasis_TypeSet(BasisVelocity,BASIS_TYPE,Err)
    !Set the basis xi number
    CALL CMISSBasis_NumberOfXiSet(BasisVelocity,NUMBER_OF_DIMENSIONS,Err)
    !Set the basis xi interpolation and number of Gauss points
    IF(NUMBER_OF_DIMENSIONS==2) THEN
      CALL CMISSBasis_InterpolationXiSet(BasisVelocity,(/BASIS_XI_INTERPOLATION_VELOCITY,BASIS_XI_INTERPOLATION_VELOCITY/),Err)
      CALL CMISSBasis_QuadratureNumberOfGaussXiSet(BasisVelocity,(/BASIS_XI_GAUSS_VELOCITY,BASIS_XI_GAUSS_VELOCITY/),Err)
    ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
      CALL CMISSBasis_InterpolationXiSet(BasisVelocity,(/BASIS_XI_INTERPOLATION_VELOCITY,BASIS_XI_INTERPOLATION_VELOCITY, & 
        & BASIS_XI_INTERPOLATION_VELOCITY/),Err)                         
      CALL CMISSBasis_QuadratureNumberOfGaussXiSet(BasisVelocity,(/BASIS_XI_GAUSS_VELOCITY,BASIS_XI_GAUSS_VELOCITY, & 
        & BASIS_XI_GAUSS_VELOCITY/),Err)
    ENDIF
    !Finish the creation of the basis
    CALL CMISSBasis_CreateFinish(BasisVelocity,Err)
  ENDIF
  !Start the creation of another basis
  IF(BASIS_XI_INTERPOLATION_PRESSURE==BASIS_XI_INTERPOLATION_SPACE) THEN
    BasisPressure=BasisSpace
  ELSE IF(BASIS_XI_INTERPOLATION_PRESSURE==BASIS_XI_INTERPOLATION_VELOCITY) THEN
    BasisPressure=BasisVelocity
  ELSE
    MESH_NUMBER_OF_COMPONENTS=MESH_NUMBER_OF_COMPONENTS+1
    !Initialise a new pressure basis
    CALL CMISSBasis_Initialise(BasisPressure,Err)
    !Start the creation of a basis
    CALL CMISSBasis_CreateStart(BASIS_NUMBER_PRESSURE,BasisPressure,Err)
    !Set the basis type (Lagrange/Simplex)
    CALL CMISSBasis_TypeSet(BasisPressure,BASIS_TYPE,Err)
    !Set the basis xi number
    CALL CMISSBasis_NumberOfXiSet(BasisPressure,NUMBER_OF_DIMENSIONS,Err)
    !Set the basis xi interpolation and number of Gauss points
    IF(NUMBER_OF_DIMENSIONS==2) THEN
      CALL CMISSBasis_InterpolationXiSet(BasisPressure,(/BASIS_XI_INTERPOLATION_PRESSURE,BASIS_XI_INTERPOLATION_PRESSURE/),Err)
      CALL CMISSBasis_QuadratureNumberOfGaussXiSet(BasisPressure,(/BASIS_XI_GAUSS_PRESSURE,BASIS_XI_GAUSS_PRESSURE/),Err)
    ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
      CALL CMISSBasis_InterpolationXiSet(BasisPressure,(/BASIS_XI_INTERPOLATION_PRESSURE,BASIS_XI_INTERPOLATION_PRESSURE, & 
        & BASIS_XI_INTERPOLATION_PRESSURE/),Err)                         
      CALL CMISSBasis_QuadratureNumberOfGaussXiSet(BasisPressure,(/BASIS_XI_GAUSS_PRESSURE,BASIS_XI_GAUSS_PRESSURE, & 
        & BASIS_XI_GAUSS_PRESSURE/),Err)
    ENDIF
    !Finish the creation of the basis
    CALL CMISSBasis_CreateFinish(BasisPressure,Err)
  ENDIF

  !
  !================================================================================================================================
  !

  !MESH

  !Start the creation of mesh nodes
  CALL CMISSNodes_Initialise(Nodes,Err)
  CALL CMISSMesh_Initialise(Mesh,Err)
!  CALL CMISSNodes_CreateStart(Region,TOTAL_NUMBER_OF_NODES,Nodes,Err)
  CALL CMISSNodes_CreateStart(Region,NUMBER_OF_NODES_VELOCITY,Nodes,Err)
  CALL CMISSNodes_CreateFinish(Nodes,Err)
  !Start the creation of the mesh
  CALL CMISSMesh_CreateStart(MeshUserNumber,Region,NUMBER_OF_DIMENSIONS,Mesh,Err)
  !Set number of mesh elements
  CALL CMISSMesh_NumberOfElementsSet(Mesh,TOTAL_NUMBER_OF_ELEMENTS,Err)
  !Set number of mesh components
  CALL CMISSMesh_NumberOfComponentsSet(Mesh,MESH_NUMBER_OF_COMPONENTS,Err)
  !Specify spatial mesh component
  CALL CMISSMeshElements_Initialise(MeshElementsSpace,Err)
  CALL CMISSMeshElements_Initialise(MeshElementsVelocity,Err)
  CALL CMISSMeshElements_Initialise(MeshElementsPressure,Err)
  MESH_COMPONENT_NUMBER_SPACE=1
  MESH_COMPONENT_NUMBER_VELOCITY=1
  MESH_COMPONENT_NUMBER_PRESSURE=1
  CALL CMISSMeshElements_CreateStart(Mesh,MESH_COMPONENT_NUMBER_SPACE,BasisSpace,MeshElementsSpace,Err)
  DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS
    CALL CMISSMeshElements_NodesSet(MeshElementsSpace,ELEMENT_NUMBER,CM%M(ELEMENT_NUMBER,1:NUMBER_OF_ELEMENT_NODES_SPACE),Err)
  ENDDO
  CALL CMISSMeshElements_CreateFinish(MeshElementsSpace,Err)
  !Specify velocity mesh component
  IF(BASIS_XI_INTERPOLATION_VELOCITY==BASIS_XI_INTERPOLATION_SPACE) THEN
    MeshElementsVelocity=MeshElementsSpace
  ELSE
    MESH_COMPONENT_NUMBER_VELOCITY=MESH_COMPONENT_NUMBER_SPACE+1
    CALL CMISSMeshElements_CreateStart(Mesh,MESH_COMPONENT_NUMBER_VELOCITY,BasisVelocity,MeshElementsVelocity,Err)
    DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS
      CALL CMISSMeshElements_NodesSet(MeshElementsVelocity,ELEMENT_NUMBER,CM%V(ELEMENT_NUMBER, & 
        & 1:NUMBER_OF_ELEMENT_NODES_VELOCITY),Err)
    ENDDO
    CALL CMISSMeshElements_CreateFinish(MeshElementsVelocity,Err)
  ENDIF
  !Specify pressure mesh component
  IF(BASIS_XI_INTERPOLATION_PRESSURE==BASIS_XI_INTERPOLATION_SPACE) THEN
    MeshElementsPressure=MeshElementsSpace
    MESH_COMPONENT_NUMBER_PRESSURE=MESH_COMPONENT_NUMBER_SPACE
  ELSE IF(BASIS_XI_INTERPOLATION_PRESSURE==BASIS_XI_INTERPOLATION_VELOCITY) THEN
    MeshElementsPressure=MeshElementsVelocity
    MESH_COMPONENT_NUMBER_PRESSURE=MESH_COMPONENT_NUMBER_VELOCITY
  ELSE
    MESH_COMPONENT_NUMBER_PRESSURE=MESH_COMPONENT_NUMBER_VELOCITY+1
    CALL CMISSMeshElements_CreateStart(Mesh,MESH_COMPONENT_NUMBER_PRESSURE,BasisPressure,MeshElementsPressure,Err)
    DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS
      CALL CMISSMeshElements_NodesSet(MeshElementsPressure,ELEMENT_NUMBER,CM%P(ELEMENT_NUMBER, & 
        & 1:NUMBER_OF_ELEMENT_NODES_PRESSURE),Err)
    ENDDO
    CALL CMISSMeshElements_CreateFinish(MeshElementsPressure,Err)
  ENDIF
  !Finish the creation of the mesh
  CALL CMISSMesh_CreateFinish(Mesh,Err)

  !
  !================================================================================================================================
  !

  !Decomposition

  !Create a decomposition
  CALL CMISSDecomposition_Initialise(Decomposition,Err)
  CALL CMISSDecomposition_CreateStart(DecompositionUserNumber,Mesh,Decomposition,Err)
  !Set the decomposition to be a general decomposition with the specified number of domains
!  CALL CMISSDecomposition_TypeSet(Decomposition,CMISS_DECOMPOSITION_USER_DEFINED_TYPE,Err)
  CALL CMISSDecomposition_TypeSet(Decomposition,CMISS_DECOMPOSITION_CALCULATED_TYPE,Err)
  CALL CMISSDecomposition_NumberOfDomainsSet(Decomposition,NumberOfComputationalNodes,Err)

  ! ElementsPerComputationalNode=INT(TOTAL_NUMBER_OF_ELEMENTS/NumberOfComputationalNodes)
  ! ComputationalNode=0
  ! ElementsInComputationalNode=0
  ! IF(NumberOfComputationalNodes>1) THEN
  !   DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS
  !     CALL CMISSDecomposition_ElementDomainSet(Decomposition,ELEMENT_NUMBER,ComputationalNode,Err)
  !     ElementsInComputationalNode=ElementsInComputationalNode+1
  !     IF(ComputationalNode<NumberOfComputationalNodes) THEN
  !       IF(ElementsInComputationalNode>ElementsPerComputationalNode) THEN
  !         ComputationalNode=ComputationalNode+1
  !         ElementsInComputationalNode=0 
  !       ENDIF
  !     ENDIF
  !     DEBUG_ElementComputationalNode(ELEMENT_NUMBER)=ComputationalNode
  !   ENDDO
  ! ENDIF

  !Finish the decomposition
  CALL CMISSDecomposition_CreateFinish(Decomposition,Err)

  !
  !================================================================================================================================
  !

  !GEOMETRIC FIELD

  !Start to create a default (geometric) field on the region
  CALL CMISSField_Initialise(GeometricField,Err)
  CALL CMISSField_CreateStart(GeometricFieldUserNumber,Region,GeometricField,Err)
!  !Set the field type
!  CALL CMISSField_TypeSet(GeometricField,CMISS_FIELD_GEOMETRIC_TYPE,Err)
  !Set the decomposition to use
  CALL CMISSField_MeshDecompositionSet(GeometricField,Decomposition,Err)
!  !Set the scaling to use
!  CALL CMISSField_ScalingTypeSet(GeometricField,CMISS_FIELD_NO_SCALING,Err)
  !Set the mesh component to be used by the field components.
  DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
    CALL CMISSField_ComponentMeshComponentSet(GeometricField,CMISS_FIELD_U_VARIABLE_TYPE,COMPONENT_NUMBER, & 
      & MESH_COMPONENT_NUMBER_SPACE,Err)
  ENDDO
  !Finish creating the field
  CALL CMISSField_CreateFinish(GeometricField,Err)
  !Update the geometric field parameters
  DO NODE_NUMBER=1,NUMBER_OF_NODES_SPACE
    DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
      VALUE=CM%N(NODE_NUMBER,COMPONENT_NUMBER)
      CALL CMISSDecomposition_NodeDomainGet(Decomposition,NODE_NUMBER,1,BoundaryNodeDomain,Err)
      IF(BoundaryNodeDomain==ComputationalNodeNumber) THEN
        CALL CMISSField_ParameterSetUpdateNode(GeometricField,CMISS_FIELD_U_VARIABLE_TYPE,CMISS_FIELD_VALUES_SET_TYPE, & 
          & 1,CMISS_NO_GLOBAL_DERIV,NODE_NUMBER,COMPONENT_NUMBER,VALUE,Err)
      ENDIF
    ENDDO
  ENDDO
  CALL CMISSField_ParameterSetUpdateStart(GeometricField,CMISS_FIELD_U_VARIABLE_TYPE,CMISS_FIELD_VALUES_SET_TYPE,Err)
  CALL CMISSField_ParameterSetUpdateFinish(GeometricField,CMISS_FIELD_U_VARIABLE_TYPE,CMISS_FIELD_VALUES_SET_TYPE,Err)



  !
  !================================================================================================================================
  !

  !EQUATIONS SETS

!  CALL CMISSField_Initialise(EquationsSetField,Err)

!  CALL CMISSField_Initialise(EquationsSetField,Err)
!    CALL CMISSField_CreateStart(EquationsSetFieldUserNumber,Region,EquationsSetField,Err)
!    CALL CMISSField_TypeSet(EquationsSetField,CMISS_FIELD_GENERAL_TYPE,Err)  
!  CALL CMISSField_CreateFinish(EquationsSetField,Err)

  CALL CMISSEquationsSet_Initialise(EquationsSetNavierStokes,Err)
  CALL CMISSField_Initialise(EquationsSetField,Err)
  CALL CMISSEquationsSet_CreateStart(EquationsSetUserNumberNavierStokes,Region,GeometricField, &
    & CMISS_EQUATIONS_SET_FLUID_MECHANICS_CLASS,CMISS_EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE, &
    & EquationsSetSubtype,EquationsSetFieldUserNumber,EquationsSetField,EquationsSetNavierStokes,Err)
  !Finish creating the equations set
  CALL CMISSEquationsSet_CreateFinish(EquationsSetNavierStokes,Err)

  H_PARAM=0.0_CMISSDP
  UMAX_PARAM=0.0_CMISSDP
  RE_PARAM=0.0_CMISSDP
  C_PARAM=0.0_CMISSDP
!   IF(SUPG_FLAG) THEN
!     DO element_number=1,TOTAL_NUMBER_OF_ELEMENTS
! !      ElementExists = .FALSE.
! !      CALL CMISSMesh_ElementExists(MESH,1,element_number,ElementExists,Err)
! !      IF(ElementExists) THEN
!         CALL CMISSField_ParameterSetAddElement(EquationsSetField,CMISS_FIELD_U_VARIABLE_TYPE,CMISS_FIELD_VALUES_SET_TYPE, &
!           & element_number,EquationsSetFieldUserNumberNavierStokesH,H_PARAM,Err)
!         CALL CMISSField_ParameterSetAddElement(EquationsSetField,CMISS_FIELD_U_VARIABLE_TYPE,CMISS_FIELD_VALUES_SET_TYPE, &
!           & element_number,EquationsSetFieldUserNumberNavierStokesUMAX,UMAX_PARAM,Err)
!         CALL CMISSField_ParameterSetAddElement(EquationsSetField,CMISS_FIELD_U_VARIABLE_TYPE,CMISS_FIELD_VALUES_SET_TYPE, &
!           & element_number,EquationsSetFieldUserNumberNavierStokesRE,RE_PARAM,Err)
!         CALL CMISSField_ParameterSetAddElement(EquationsSetField,CMISS_FIELD_U_VARIABLE_TYPE,CMISS_FIELD_VALUES_SET_TYPE, &
!           & element_number,EquationsSetFieldUserNumberNavierStokesC,C_PARAM,Err)
! !      ENDIF 
!     END DO
!   ENDIF


  !
  !================================================================================================================================
  !

  !DEPENDENT FIELDS

  !Create the equations set dependent field variables for dynamic Navier-Stokes
  CALL CMISSField_Initialise(DependentFieldNavierStokes,Err)
  CALL CMISSEquationsSet_DependentCreateStart(EquationsSetNavierStokes,DependentFieldUserNumberNavierStokes, & 
    & DependentFieldNavierStokes,Err)
  !Set the mesh component to be used by the field components.
  DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
    CALL CMISSField_ComponentMeshComponentSet(DependentFieldNavierStokes,CMISS_FIELD_U_VARIABLE_TYPE,COMPONENT_NUMBER, & 
      & MESH_COMPONENT_NUMBER_VELOCITY,Err)
    CALL CMISSField_ComponentMeshComponentSet(DependentFieldNavierStokes,CMISS_FIELD_DELUDELN_VARIABLE_TYPE,COMPONENT_NUMBER, & 
      & MESH_COMPONENT_NUMBER_VELOCITY,Err)
  ENDDO
  COMPONENT_NUMBER=NUMBER_OF_DIMENSIONS+1
  CALL CMISSField_ComponentMeshComponentSet(DependentFieldNavierStokes,CMISS_FIELD_U_VARIABLE_TYPE,COMPONENT_NUMBER, & 
    & MESH_COMPONENT_NUMBER_PRESSURE,Err)
  CALL CMISSField_ComponentMeshComponentSet(DependentFieldNavierStokes,CMISS_FIELD_DELUDELN_VARIABLE_TYPE,COMPONENT_NUMBER, & 
    & MESH_COMPONENT_NUMBER_PRESSURE,Err)
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSet_DependentCreateFinish(EquationsSetNavierStokes,Err)

  !Initialise dependent field
  DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
    CALL CMISSField_ComponentValuesInitialise(DependentFieldNavierStokes,CMISS_FIELD_U_VARIABLE_TYPE,CMISS_FIELD_VALUES_SET_TYPE, & 
      & COMPONENT_NUMBER,INITIAL_FIELD_NAVIER_STOKES(COMPONENT_NUMBER),Err)
  ENDDO

  !
  !================================================================================================================================
  !

  !MATERIALS FIELDS

  !Create the equations set materials field variables for static Navier-Stokes
  CALL CMISSField_Initialise(MaterialsFieldNavierStokes,Err)
  CALL CMISSEquationsSet_MaterialsCreateStart(EquationsSetNavierStokes,MaterialsFieldUserNumberNavierStokes, & 
    & MaterialsFieldNavierStokes,Err)
  !Finish the equations set materials field variables
  CALL CMISSEquationsSet_MaterialsCreateFinish(EquationsSetNavierStokes,Err)

  ! Materials parameters, viscosity and density
  CALL CMISSField_ComponentValuesInitialise(MaterialsFieldNavierStokes,CMISS_FIELD_U_VARIABLE_TYPE,CMISS_FIELD_VALUES_SET_TYPE, & 
    & MaterialsFieldUserNumberNavierStokesMu,MU_PARAM_NAVIER_STOKES,Err)
  CALL CMISSField_ComponentValuesInitialise(MaterialsFieldNavierStokes,CMISS_FIELD_U_VARIABLE_TYPE,CMISS_FIELD_VALUES_SET_TYPE, & 
    & MaterialsFieldUserNumberNavierStokesRho,RHO_PARAM_NAVIER_STOKES,Err)

!   !Fluid metrics
!     IF(.NOT.ALLOCATED(H_PARAM)) ALLOCATE(H_PARAM(TOTAL_NUMBER_OF_ELEMENTS))
!   H_PARAM(1:TOTAL_NUMBER_OF_ELEMENTS)=0.0_CMISSDP
!   DO element_number=1,TOTAL_NUMBER_OF_ELEMENTS
!     CALL CMISSField_ComponentValuesInitialise(MaterialsFieldNavierStokes,CMISS_FIELD_U_VARIABLE_TYPE,CMISS_FIELD_VALUES_SET_TYPE, & 
!       & MaterialsFieldUserNumberNavierStokesH,H_PARAM(element_number),Err)
!   END DO

  !
  !================================================================================================================================
  !

  !EQUATIONS

  !Create the equations set equations
  CALL CMISSEquations_Initialise(EquationsNavierStokes,Err)
  CALL CMISSEquationsSet_EquationsCreateStart(EquationsSetNavierStokes,EquationsNavierStokes,Err)
  !Set the equations matrices sparsity type
  CALL CMISSEquations_SparsityTypeSet(EquationsNavierStokes,CMISS_EQUATIONS_SPARSE_MATRICES,Err)
  !Set the equations set output
  CALL CMISSEquations_OutputTypeSet(EquationsNavierStokes,EQUATIONS_NAVIER_STOKES_OUTPUT,Err)
  !Finish the equations set equations
  CALL CMISSEquationsSet_EquationsCreateFinish(EquationsSetNavierStokes,Err)


  !
  !================================================================================================================================
  !

  !PROBLEMS

  !Start the creation of a problem.
  CALL CMISSProblem_Initialise(Problem,Err)
  CALL CMISSControlLoop_Initialise(ControlLoop,Err)
  CALL CMISSProblem_CreateStart(ProblemUserNumber,Problem,Err)
  !Set the problem to be a dynamic Navier-Stokes problem
  CALL CMISSProblem_SpecificationSet(Problem,CMISS_PROBLEM_FLUID_MECHANICS_CLASS,CMISS_PROBLEM_NAVIER_STOKES_EQUATION_TYPE, &
    & ProblemSubtype,Err)
  !Finish the creation of a problem.
  CALL CMISSProblem_CreateFinish(Problem,Err)
  !Start the creation of the problem control loop
  CALL CMISSProblem_ControlLoopCreateStart(Problem,Err)
  !Get the control loop
  CALL CMISSProblem_ControlLoopGet(Problem,CMISS_CONTROL_LOOP_NODE,ControlLoop,Err)
  !Set the times
  CALL CMISSControlLoop_TimesSet(ControlLoop,DYNAMIC_SOLVER_NAVIER_STOKES_START_TIME,DYNAMIC_SOLVER_NAVIER_STOKES_STOP_TIME, & 
    & DYNAMIC_SOLVER_NAVIER_STOKES_TIME_INCREMENT,Err)
  !Set the output timing
  CALL CMISSControlLoop_TimeOutputSet(ControlLoop,DYNAMIC_SOLVER_NAVIER_STOKES_OUTPUT_FREQUENCY,Err)
  !Finish creating the problem control loop
  CALL CMISSProblem_ControlLoopCreateFinish(Problem,Err)

  !
  !================================================================================================================================
  !

  !SOLVERS

  !Start the creation of the problem solvers
  CALL CMISSSolver_Initialise(DynamicSolverNavierStokes,Err)
  CALL CMISSSolver_Initialise(NonlinearSolverNavierStokes,Err)
  CALL CMISSSolver_Initialise(LinearSolverNavierStokes,Err)
  CALL CMISSProblem_SolversCreateStart(Problem,Err)
  !Get the dynamic dymamic solver
  CALL CMISSProblem_SolverGet(Problem,CMISS_CONTROL_LOOP_NODE,SolverNavierStokesUserNumber,DynamicSolverNavierStokes,Err)
  !Set the output type
  CALL CMISSSolver_OutputTypeSet(DynamicSolverNavierStokes,DYNAMIC_SOLVER_NAVIER_STOKES_OUTPUT_TYPE,Err)
  !Set theta
  CALL CMISSSolver_DynamicThetaSet(DynamicSolverNavierStokes,DYNAMIC_SOLVER_NAVIER_STOKES_THETA,Err)
!   CALL CMISSSolverDynamicDynamicSet(DynamicSolverNavierStokes,.TRUE.,Err)
  !Get the dynamic nonlinear solver
  CALL CMISSSolver_DynamicNonlinearSolverGet(DynamicSolverNavierStokes,NonlinearSolverNavierStokes,Err)
  !Set the nonlinear Jacobian type
  CALL CMISSSolver_NewtonJacobianCalculationTypeSet(NonlinearSolverNavierStokes, &
    & CMISS_SOLVER_NEWTON_JACOBIAN_EQUATIONS_CALCULATED,Err)
!  CALL CMISSSolver_NewtonJacobianCalculationTypeSet(NonlinearSolverNavierStokes,CMISS_SOLVER_NEWTON_JACOBIAN_FD_CALCULATED,Err)
  !Set the output type
  CALL CMISSSolver_OutputTypeSet(NonlinearSolverNavierStokes,NONLINEAR_SOLVER_NAVIER_STOKES_OUTPUT_TYPE,Err)
  !Set the solver settings
  CALL CMISSSolver_NewtonAbsoluteToleranceSet(NonlinearSolverNavierStokes,ABSOLUTE_TOLERANCE,Err)
  CALL CMISSSolver_NewtonRelativeToleranceSet(NonlinearSolverNavierStokes,RELATIVE_TOLERANCE,Err)
  CALL CMISSSolver_NewtonMaximumIterationsSet(NonlinearSolverNavierStokes,MAXIMUM_ITERATIONS,Err)
  !Get the dynamic nonlinear linear solver
  CALL CMISSSolver_NewtonLinearSolverGet(NonlinearSolverNavierStokes,LinearSolverNavierStokes,Err)
  !Set the output type
  CALL CMISSSolver_OutputTypeSet(LinearSolverNavierStokes,LINEAR_SOLVER_NAVIER_STOKES_OUTPUT_TYPE,Err)
  !Set the solver settings
  IF(LINEAR_SOLVER_NAVIER_STOKES_DIRECT_FLAG) THEN
    CALL CMISSSolver_LinearTypeSet(LinearSolverNavierStokes,CMISS_SOLVER_LINEAR_DIRECT_SOLVE_TYPE,Err)
    CALL CMISSSolver_LibraryTypeSet(LinearSolverNavierStokes,CMISS_SOLVER_MUMPS_LIBRARY,Err)
  ELSE
    CALL CMISSSolver_LinearTypeSet(LinearSolverNavierStokes,CMISS_SOLVER_LINEAR_ITERATIVE_SOLVE_TYPE,Err)
    CALL CMISSSolver_LinearIterativeMaximumIterationsSet(LinearSolverNavierStokes,MAXIMUM_ITERATIONS,Err)
    CALL CMISSSolver_LinearIterativeDivergenceToleranceSet(LinearSolverNavierStokes,DIVERGENCE_TOLERANCE,Err)
    CALL CMISSSolver_LinearIterativeRelativeToleranceSet(LinearSolverNavierStokes,RELATIVE_TOLERANCE,Err)
    CALL CMISSSolver_LinearIterativeAbsoluteToleranceSet(LinearSolverNavierStokes,ABSOLUTE_TOLERANCE,Err)
    CALL CMISSSolver_LinearIterativeGMRESRestartSet(LinearSolverNavierStokes,RESTART_VALUE,Err)
  ENDIF



  !Finish the creation of the problem solver
  CALL CMISSProblem_SolversCreateFinish(Problem,Err)



  !
  !================================================================================================================================
  !

  !SOLVER EQUATIONS


  !Start the creation of the problem solver equations
  CALL CMISSSolver_Initialise(DynamicSolverNavierStokes,Err)
  CALL CMISSSolverEquations_Initialise(SolverEquationsNavierStokes,Err)

  CALL CMISSProblem_SolverEquationsCreateStart(Problem,Err)
  !Get the dynamic solver equations
  CALL CMISSProblem_SolverGet(Problem,CMISS_CONTROL_LOOP_NODE,SolverNavierStokesUserNumber,DynamicSolverNavierStokes,Err)
  CALL CMISSSolver_SolverEquationsGet(DynamicSolverNavierStokes,SolverEquationsNavierStokes,Err)
  !Set the solver equations sparsity
  CALL CMISSSolverEquations_SparsityTypeSet(SolverEquationsNavierStokes,CMISS_SOLVER_SPARSE_MATRICES,Err)
  !Add in the equations set
  CALL CMISSSolverEquations_EquationsSetAdd(SolverEquationsNavierStokes,EquationsSetNavierStokes,EquationsSetIndex,Err)
  !Finish the creation of the problem solver equations
  CALL CMISSProblem_SolverEquationsCreateFinish(Problem,Err)



  !-----------------------------------------------------------------------------------------------------------
  !BOUNDARY CONDITIONS
  !-----------------------------------------------------------------------------------------------------------
  !Start the creation of the equations set boundary conditions for Stokes
  CALL CMISSBoundaryConditions_Initialise(BoundaryConditionsNavierStokes,Err)
!  CALL CMISSEquationsSetBoundaryConditionsCreateStart(EquationsSetNavierStokes,BoundaryConditionsNavierStokes,Err)
  CALL CMISSSolverEquations_BoundaryConditionsCreateStart(SolverEquationsNavierStokes,BoundaryConditionsNavierStokes,Err)
  !Set fixed wall nodes
  IF(FIXED_WALL_NODES_NAVIER_STOKES_FLAG) THEN
    DO NODE_COUNTER=1,NUMBER_OF_FIXED_WALL_NODES_NAVIER_STOKES
      NODE_NUMBER=FIXED_WALL_NODES_NAVIER_STOKES(NODE_COUNTER)
      CONDITION=CMISS_BOUNDARY_CONDITION_FIXED
      CALL CMISSDecomposition_NodeDomainGet(Decomposition,NODE_NUMBER,1,BoundaryNodeDomain,Err)
      IF(BoundaryNodeDomain==ComputationalNodeNumber) THEN
        DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
          VALUE=0.0_CMISSDP
!          CALL CMISSBoundaryConditions_SetNode(BoundaryConditionsNavierStokes,CMISS_FIELD_U_VARIABLE_TYPE,1,CMISS_NO_GLOBAL_DERIV, & 
!            & NODE_NUMBER,COMPONENT_NUMBER,CONDITION,VALUE,Err)
          CALL CMISSBoundaryConditions_SetNode(BoundaryConditionsNavierStokes,DependentFieldNavierStokes, &
            & CMISS_FIELD_U_VARIABLE_TYPE,1,CMISS_NO_GLOBAL_DERIV,NODE_NUMBER,COMPONENT_NUMBER,CONDITION,VALUE,Err)
        ENDDO
      ENDIF
    ENDDO
  ENDIF
  !Set velocity boundary conditions
  IF(LID_NODES_NAVIER_STOKES_FLAG) THEN
     DO NODE_COUNTER=1,NUMBER_OF_LID_NODES_NAVIER_STOKES
      NODE_NUMBER=LID_NODES_NAVIER_STOKES(NODE_COUNTER)
      CONDITION=CMISS_BOUNDARY_CONDITION_FIXED
      CALL CMISSDecomposition_NodeDomainGet(Decomposition,NODE_NUMBER,1,BoundaryNodeDomain,Err)
      IF(BoundaryNodeDomain==ComputationalNodeNumber) THEN
        DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
          VALUE=BOUNDARY_CONDITIONS_NAVIER_STOKES(COMPONENT_NUMBER)
!          CALL CMISSBoundaryConditions_SetNode(BoundaryConditionsNavierStokes,CMISS_FIELD_U_VARIABLE_TYPE,1,CMISS_NO_GLOBAL_DERIV, & 
!            & NODE_NUMBER,COMPONENT_NUMBER,CONDITION,VALUE,Err)
          CALL CMISSBoundaryConditions_SetNode(BoundaryConditionsNavierStokes,DependentFieldNavierStokes, &
            & CMISS_FIELD_U_VARIABLE_TYPE,1,CMISS_NO_GLOBAL_DERIV,NODE_NUMBER,COMPONENT_NUMBER,CONDITION,VALUE,Err)
        ENDDO
      ENDIF
    ENDDO
  ENDIF
  !Finish the creation of the equations set boundary conditions
  CALL CMISSSolverEquations_BoundaryConditionsCreateFinish(SolverEquationsNavierStokes,Err)


  !
  !================================================================================================================================
  !

  !RUN SOLVERS

  !PETSc error handling
  !CALL PETSC_ERRORHANDLING_SET_ON(ERR,ERROR,*999)

  !Solve the problem
  WRITE(*,'(A)') "Solving problem..."
  CALL CMISSProblem_Solve(Problem,Err)
  WRITE(*,'(A)') "Problem solved!"
! 
  !
  !================================================================================================================================
  !

  !OUTPUT

    ! CALL CMISSFieldMLOutputTypeInitialise( outputInfo, err )
    ! CALL CMISSFieldML_OutputCreate( Mesh, outputDirectory, basename, dataFormat, outputInfo, err )
    ! CALL CMISSFieldML_OutputAddImport( outputInfo, "coordinates.rc.3d", typeHandle, err )
    ! CALL CMISSFieldML_OutputAddField( outputInfo, baseName//".geometric", dataFormat, GeometricField, &
    !   & CMISS_FIELD_U_VARIABLE_TYPE, CMISS_FIELD_VALUES_SET_TYPE, err )
    ! CALL CMISSFieldML_OutputAddFieldComponents( outputInfo, typeHandle, baseName//".velocity", dataFormat, &
    !   & DependentFieldNavierStokes, (/1,2,3/), CMISS_FIELD_U_VARIABLE_TYPE, CMISS_FIELD_VALUES_SET_TYPE, err )
    ! CALL CMISSFieldML_OutputAddImport( outputInfo, "real.1d", typeHandle, err )
    ! CALL CMISSFieldML_OutputAddFieldComponents( outputInfo, typeHandle, baseName//".pressure", dataFormat, &
    !   & DependentFieldNavierStokes, (/4/), CMISS_FIELD_U_VARIABLE_TYPE, CMISS_FIELD_VALUES_SET_TYPE, err )
    ! CALL CMISSFieldML_OutputWrite( outputInfo, outputFilename, err )
    ! CALL CMISSFieldMLOutputTypeFinalise( outputInfo, err )

  ! EXPORT_FIELD_IO=.FALSE.
  ! IF(EXPORT_FIELD_IO) THEN
  !   WRITE(*,'(A)') "Exporting fields..."
  !   CALL CMISSFields_Initialise(Fields,Err)
  !   CALL CMISSFields_Create(Region,Fields,Err)
  !   CALL CMISSFields_NodesExport(Fields,"DynamicNavierStokes","FORTRAN",Err)
  !   CALL CMISSFields_ElementsExport(Fields,"DynamicNavierStokes","FORTRAN",Err)
  !   CALL CMISSFields_Finalise(Fields,Err)
  !   WRITE(*,'(A)') "Field exported!"
  ! ENDIF
  
  !Finialise CMISS
  CALL CMISSFinalise(Err)

  WRITE(*,'(A)') "Program successfully completed."
  
  STOP

END PROGRAM LIDDRIVENCAVITY
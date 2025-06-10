$title Spatial-explicit Energy System Optimisation Model - SELARU Indonesia
$onText
Version 3.0, November 2023.
Written by Bintang Yuwono
(license)
(reference)
(link)
$offText

$offSymXRef
$offSymList
option limRow = 0, limCol = 0;
option solPrint = silent;

$set spatialscenario     "hires"
$set climatescenario     "NZ1"

$set inputfile                   "input_%spatialscenario%.gdx"
$set input_co2target             "input_co2target.gdx"



*===============================================================================
*INPUT DATASET PREPARATION
*===============================================================================
*Loading .xlsx file and writing into .gdx file
*$set InputFile 'input.xlsx'
*$call gdxXrw %InputFile% o=input.gdx skipempty=0 squeeze=n trace=3 index=index!B1

*Defining names for model input dataset in .gdx file
parameters       par_years(*,*)  "Timesteps and planning horizon (y,'category')"
                 par_rimp(*,*)  "Import regions (rimp,'category')"
                 par_r(*,*)  "Domestic regions (r,'category')"
                 par_nodes(*,*)  "Nodes of supply-demand balancing locations (n,'category')"
                 par_map_rXn(*,*,*)  "Mapping of region and node (r,n,'category')"
                 par_plrsv_margin(*,*)  "Planning reserve margin (n,y)"
                 par_demand(*,*)  "Electricity Demand (n,y)"
                 par_sit_eg(*,*)  "Sitting of power generation (n,'category')"
                 par_sit_sub(*,*)  "Sitting of transformer-substation (n,'category')"
                 par_sit_tre(*,*,*)  "Sitting of transmission line (n,n2,'category')"
                 par_sit_trc(*,*,*)  "Sitting of CO2 transport (n,n2,'category')"
                 par_kv(*,*)  "Voltage classes (kv,'category')"
                 par_eg(*,*)  "Electricity generation infrastructure (eg,'category')"
                 par_sub(*,*)  "Transformer-substation infrastructure (kv,'category')"
                 par_tre(*,*)  "Transmission line infrastructure (kv,'category')"
                 par_trc(*,*)  "CO2 transport infrastructure (trc,'category')"
                 par_csink(*,*)  "CO2 sinks (n,'category')"
                 par_fuel(*,*)  "Fuels (f,'category')"
                 par_fuel_local(*,*)  "Fuel, locally sourced (n,f)"
                 par_fuel_regional_nXr(*,*,*)  "Fuel, domestically sourced from other region (n,r,f)"
                 par_fuel_import_nXrimp(*,*,*)  "Fuel, imported from other import region (n,rimp,f)"
                 par_fuel_regional_rXr(*,*,*)  "Fuel, domestically sourced from other region (r,r,f)"
                 par_fuel_import_rXrimp(*,*,*)  "Fuel, imported from other import region (r,rimp,f)"
                 par_rsc_fuel_local(*,*)  "Fuel resource potential at nodal (n,'category')"
                 par_rsc_fuel_regional(*,*)  "Fuel resource potential at regional (r,'category')"
                 par_rsc_geot(*,*)  "Geothermal resource (n,'category')"
                 par_rsc_hydro(*,*)  "Hydropower resource (n,'category')"
                 par_rsc_usw(*,*)  "Utility scale solar and wind resource (n,'category')"
                 par_rsc_dgen(*,*)  "Distributed generation resource (n,'category')"
                 par_stk_eg(*,*,*,*)  "Stock build capacity of electricity generation infrastructure(n,eg,v,'category')"
                 par_stk_sub(*,*,*)  "Stock build capacity of electricity transformer-substation(n,kv,'category')"
                 par_stk_tre(*,*,*,*)  "Stock build capacity of electricity transmission line(n,n2,kv,'category')"
*                 par_stk_trc(*,*,*,*)  "Stock build capacity of CO2 transport (n,n2,trc,'category')"
                 par_cod_eg(*,*,*,*)  "Prescribed capacity of electricity generation infrastructure (n,eg,v,'category')"
                 par_cod_tre(*,*,*,*,*)  "Prescribed capacity of electricity transmission line (n,n2,kv,y,'category')"
;
*Loading values for model input dataset from reading .gdx file
$gdxIn   %inputfile%
$loaddc  par_years
$loaddc  par_rimp
$loaddc  par_r
$loaddc  par_nodes
$loaddc  par_map_rXn
$loaddc  par_plrsv_margin
$loaddc  par_demand
$loaddc  par_sit_eg
$loaddc  par_sit_sub
$loaddc  par_sit_tre
$loaddc  par_sit_trc
$loaddc  par_kv
$loaddc  par_eg
$loaddc  par_sub
$loaddc  par_tre
$loaddc  par_trc
$loaddc  par_csink
$loaddc  par_fuel
$loaddc  par_fuel_local
$loaddc  par_fuel_regional_nXr
$loaddc  par_fuel_import_nXrimp
$loaddc  par_fuel_regional_rXr
$loaddc  par_fuel_import_rXrimp
$loaddc  par_rsc_fuel_local
$loaddc  par_rsc_fuel_regional
$loaddc  par_rsc_geot
$loaddc  par_rsc_hydro
$loaddc  par_rsc_usw
$loaddc  par_rsc_dgen
$loaddc  par_stk_eg
$loaddc  par_stk_sub
$loaddc  par_stk_tre
*$loaddc  par_stk_trc
$loaddc  par_cod_eg
$loaddc  par_cod_tre



*===============================================================================
*# SETS AND INDICES
*===============================================================================
* TEMPORAL
sets     yall  "All years"
         y(yall)  "Years included in a model instance"
         yfirst(yall)  "Base year of model run"
         ylast(yall)  "Last year of model run"
         model_horizon(yall)  "Years considered in model instance";
$gdxIn   %inputfile%
$loaddc  yall
alias    (yall,yall2);
alias    (yall,yall3);
alias    (yall,v);
alias    (y,y2);
alias    (v,v2);
yfirst(yall) = yes$[par_years(yall,'y.first')];
ylast(yall) = yes$[par_years(yall,'y.last')];
model_horizon(yall)$[(ORD(yall) >= sum{yall2$[yfirst(yall2)], ORD(yall2)}) AND (ORD(yall) <= sum{yall2$[ylast(yall2)], ORD(yall2)})] = yes;
y(yall) = yes$[model_horizon(yall)];

sets     y_sequence(yall,yall2)  "Sequence of periods (y,y2) over the model horizon"
         map_period(yall,yall2)  "Mapping of future periods (y,y2) over the model horizon";
y_sequence(yall,yall2)$[ORD(yall)+1 = ORD(yall2)] = yes;
map_period(yall,yall2)$[ORD(yall) <= ORD(yall2)] = yes;

* SPATIAL LOCATION
sets     rimp  "Regions, import"
         r  "Regions, domestic"
         n  "Nodes";
$gdxIn   %inputfile%
$loaddc  rimp
$loaddc  r
$loaddc  n
alias    (n,n2);
alias    (r,r2);

* SPATIAL CONNECTION
sets     map_nXr(n,r) "Mapping of node (n) and cluster region (r)"
         trade_nXr(n,r) "Domestic trade between node (n) and cluster region (r)"
         trade_nXrimp(n,rimp) "Import trade between node (n) and import region (rimp)"
         trade_rXr(r,r2) "Domestic trade between node (n) and cluster region (r)"
         trade_rXrimp(r,rimp) "Import trade between node (n) and import region (rimp)";
map_nXr(n,r) = yes$[par_map_rXn(r,n,'area_sqkm')];
trade_nXr(n,r) = yes$[par_fuel_regional_nXr(n,r,'oil')];
trade_nXrimp(n,rimp) = yes$[par_fuel_import_nXrimp(n,rimp,'oil')];
trade_rXr(r,r2) = yes$[par_fuel_regional_rXr(r,r,'oil')];
trade_rXrimp(r,rimp) = yes$[par_fuel_import_rXrimp(r,rimp,'oil')];


*_ ELECTRICITY TRANSMISSION INFRASTRUCTURE
sets     kv  "Voltage classes"
         typ_oprsv  "Types of operating reserve"
         cat_oprsv  "Categories of operating reserve"
         tre_NEWc(kv)  "Transmission line infrastructure (kv) with continuos capacity addition"
         tre_NEWi(kv)  "Transmission line infrastructure (kv) with integer capacity addition";
$gdxIn   %inputfile%
$loaddc  kv
$loaddc  typ_oprsv
$loaddc  cat_oprsv
alias    (kv,kv2);
tre_NEWc(kv) = yes$[par_kv(kv,'NEWc') eq 1];
tre_NEWi(kv) = yes$[par_kv(kv,'NEWi') eq 1];
parameters       val_kv(kv)  "Value (order) of voltage class";
val_kv(kv) = par_kv(kv,'kv_val');

*_ ELECTRICITY GENERATION INFRASTRUCTURE
sets     eg  "Types of power generation infrastructure"
         greg  "Groups of power generation infrastructure"
         eg_greg(eg,greg)  "Grouping of power generation infrastructure"
         eg_NEWc(eg)  "Power generation infrastructure (eg) with continuos capacity addition"
         eg_NEWi(eg)  "Power generation infrastructure (eg) with integer capacity addition"
         eg_rsvcap(eg)  "Power generation infrastructure (eg) that contributes firm capacities to planning reserve requirements"
         eg_firing(eg)  "Fuel-firing power generation infrastructure (eg)"
         eg_cofiring(eg)  "Co-firing Coal-Biomass power generation infrastructure (eg)"
         eg_chp(eg)  "Combined Heat-Power (CHP) generation infrastructure (eg)"
         eg_largescale(eg)  "Large-scale power generation infrastructure (eg)"
         eg_largethermal(eg) "Large-scale thermal power generation infrastructure (eg)"
         eg_gasturbine(eg)  "Gas Turbine power generation infrastructure (eg)"
         eg_ice(eg)  "Internal Combustion Engine (ICE) power generation infrastructure (eg)"
         eg_bioreactor(eg)  "Biogas tank reactor coupled power generation infrastructure (eg)"
         eg_nuclear(eg)  "Nuclear power generation infrastructure (eg)"
         eg_res(eg)  "RES-based power generation infrastructure (eg)"
         eg_geot(eg)  "Geothermal power generation infrastructure (eg)"
         eg_hydd(eg)  "Hydropower, Dam power generation infrastructure (eg)"
         eg_hydr(eg)  "Mini-Hydropower, Run-off-River power generation infrastructure (eg)"
         eg_hydrr(eg)  "Micro-Hydropower Run-off-River power generation infrastructure (eg)"
         eg_winn(eg)  "Onshore Wind-power power generation infrastructure (eg)"
         eg_csp(eg)  "Concentrating Solar Power (CSP) power generation infrastructure (eg)"
         eg_upv(eg)  "Utility-scale PhotoVoltaic (UPV) power generation infrastructure (eg)"
         eg_dpv(eg)  "Distributed PV (DPV) power generation infrastructure (eg)"
         eg_usw(eg)  "Utility-scale solar and wind power generation infrastructure (eg)"
         eg_dgen(eg)  "Distributed power generation infrastructure (eg)";
$gdxIn   %inputfile%
$loaddc  eg
$loaddc  greg
eg_greg(eg,greg) = yes$[par_eg(eg,greg) eq 1];
eg_NEWc(eg) = yes$[par_eg(eg,'NEWc') eq 1];
eg_NEWi(eg) = yes$[par_eg(eg,'NEWi') eq 1];
eg_rsvcap(eg) = yes$[par_eg(eg,'rsvcap') eq 1];
eg_firing(eg) = yes$[par_eg(eg,'firing') eq 1];
eg_cofiring(eg) = yes$[par_eg(eg,'cofiring') eq 1];
eg_chp(eg) = yes$[par_eg(eg,'chp') eq 1];
eg_largescale(eg) = yes$[par_eg(eg,'largescale') eq 1];
eg_largethermal(eg) = yes$[par_eg(eg,'largethermal') eq 1];
eg_gasturbine(eg) = yes$[par_eg(eg,'gasturbine') eq 1];
eg_ice(eg) = yes$[par_eg(eg,'engine') eq 1];
eg_bioreactor(eg) = yes$[par_eg(eg,'bioreactor') eq 1];
eg_nuclear(eg) = yes$[par_eg(eg,'nuclear') eq 1];
eg_res(eg) = yes$[par_eg(eg,'res-e') eq 1];
eg_geot(eg) = yes$[par_eg(eg,'geothermal') eq 1];
eg_hydd(eg) = yes$[par_eg(eg,'hydropower') eq 1];
eg_hydr(eg) = yes$[par_eg(eg,'minihydro') eq 1];
eg_hydrr(eg) = yes$[par_eg(eg,'microhydro') eq 1];
eg_winn(eg) = yes$[par_eg(eg,'wind_ons') eq 1];
eg_csp(eg) = yes$[par_eg(eg,'sol_csp') eq 1];
eg_upv(eg) = yes$[par_eg(eg,'sol_upv') eq 1];
eg_dpv(eg) = yes$[par_eg(eg,'sol_dpv') eq 1];
eg_usw(eg) = yes$[par_eg(eg,'usw') eq 1];
eg_dgen(eg) = yes$[par_eg(eg,'dgen') eq 1];

*_ FUELS
sets     f  "Types of fuel"
         bio(f)  "Bioenergy fuels"
         biom(f)  "Biomass"
         biod(f)  "Biodiesel"
         biol(f)  "Bioethanol"
         biog(f)  "Biogas"
         fos(f)  "Fossil fuels"
         coa(f)  "Coal"
         oil(f)  "Oil"
         gas(f)  "Natural gas"
         nuc(f)  "Nuclear fuels";
$gdxIn   %inputfile%
$loaddc  f
bio(f) = yes$[par_fuel(f,'bioenergy') eq 1];
biom(f) = yes$[par_fuel(f,'biom') eq 1];
biod(f) = yes$[par_fuel(f,'biod') eq 1];
biol(f) = yes$[par_fuel(f,'biol') eq 1];
biog(f) = yes$[par_fuel(f,'biog') eq 1];
fos(f) = yes$[par_fuel(f,'fossil') eq 1];
coa(f) = yes$[par_fuel(f,'coa') eq 1];
oil(f) = yes$[par_fuel(f,'oil') eq 1];
gas(f) = yes$[par_fuel(f,'gas') eq 1];
nuc(f) = yes$[par_fuel(f,'nuc') eq 1];

*_ CO2 TRANSPORT INFRASTRUCTURE
sets     trc  "Types of CO2 transport line infrastructure"
         trc_NEWc(trc)  "CO2 transport line infrastructure with continuos capacity addition"
         trc_NEWi(trc)  "CO2 transport line with integer capacity addition";
$gdxIn   %inputfile%
$loaddc  trc
trc_NEWc(trc) = yes$[par_trc(trc,'NEWc') eq 1];
trc_NEWi(trc) = yes$[par_trc(trc,'NEWi') eq 1];

*_ TECHNOLOGY/INFRASTRUCTURE SITTING
sets     sit_eg(n,eg)  "Sitting of electricity generation infrastructure (eg) at node (n)"
         sit_sub(n,kv)  "Sitting of electricity transformer-substation infrastructure (sub) at node (n)"
         sit_tre(n,n2,kv)  "Sitting of electricity transmission line infrastructure (tre) from node (n) to another node (n2)"
         sit_trc(n,n2,trc)  "Sitting of CO2 transport infrastructure (trc) from node (n) to another node (n2)"
         csink(n)  "Node (n) with CO2 sink"
;
sit_eg(n,eg) = yes$[par_sit_eg(n,eg) eq 1];
sit_sub(n,kv) = yes$[par_sit_sub(n,kv) eq 1];
sit_tre(n,n2,kv) = yes$[par_sit_tre(n,n2,kv) eq 1];
sit_trc(n,n2,trc) = yes$[par_sit_trc(n,n2,trc) eq 1];
csink(n) = yes$[par_csink(n,'room_co2storage')];

sets     eg_feas_ybase(eg)  "Power generation infrastructure (eg) that are feasible to add at base year"
         eg_feas_yall(eg)  "Power generation infrastructure (eg) that are feasible to add at future years";
eg_feas_ybase(eg) = yes$[par_eg(eg,'feas_ybase') eq 1];
eg_feas_yall(eg) = yes$[par_eg(eg,'feas_yall') eq 1];

sets     tre_feas_ybase(n,n2,kv)  "Electricity transmission line infrastructure (tre) from node (n) to another node (n2) that are feasible to add at base year";
tre_feas_ybase(n,n2,kv) = yes$[sum{(kv2)$[val_kv(kv2) >= val_kv(kv)], par_stk_tre(n,n2,kv,'stk_MW')} > 0]



*===============================================================================
*# PARAMETERS
*===============================================================================
*_ UNIT CONVERSION
parameters       gw_tj  "GW/TJ" /0.28/
                 gw_pj  "GW/PJ" /277.78/;

*_ FINANCIAL
parameters       fct_presentvalue(yall)  "Factor of present value of money relative to base year"
                 fct_inflation(yall)  "Factor of price inflation relative to base year";
fct_presentvalue(yall) = par_years(yall,'f_pv');
fct_inflation(yall) = par_years(yall,'f_inflate');

*_ TEMPORAL
parameters       fullhours  "Full hours in a year"  /8760/
                 fulldays  "Full days in a year"  /365.25/
                 y_length(yall)  "Length of year-step"
                 yrbase_val  "Base year";
y_length(yall) = par_years(yall,"y_length");
$gdxIn   %inputfile%
$loaddc  yrbase_val

*_ SPATIAL
parameters       distance_onshore_tre(n,n2)  "(km) Total distance onshore electricity transmission line from node (n) to another location (n2)"
                 distance_offshore_tre(n,n2)  "(km) Total distance offshore electricity transmission line from node (n) to another location (n2)";
distance_onshore_tre(n,n2) = par_sit_tre(n,n2,'onshore_km');
distance_offshore_tre(n,n2) = par_sit_tre(n,n2,'offshore_km');

parameters       distance_onshore_trc(n,n2)  "(km) Total distance onshore CO2 transport line from node (n) to another location (n2)"
                 distance_offshore_trc(n,n2)  "(km) Total distance offshore CO2 transport line from node (n) to another location (n2)";
distance_onshore_trc(n,n2) = par_sit_trc(n,n2,'onshore_km');
distance_offshore_trc(n,n2) = par_sit_trc(n,n2,'offshore_km');

*_ ELECTRICITY DEMAND
parameters       D_ely(n,yall)  "(GWh/year) Demand of electricity at node (n) in year (yall)"
                 load_factor  "Load factor of (national) grid, average production per peak load"
                 Dpeak_ely(n,yall)  "(MW) Peak demand of electricity at node (n) in year (yall)";
D_ely(n,yall) = par_demand(n,yall) /1000;
$gdxIn   %inputfile%
$loaddc  load_factor
Dpeak_ely(n,yall) = par_demand(n,yall)*(1/load_factor)*(1/fullhours);

*_ PLANNING RESERVE
parameters       tgt_plrsv_margin  "Target planning reserve margin"
                 plrsv_margin(n,yall)  "Planning reserve margin at node (n) in year (yall)";
$gdxIn   %inputfile%
$loaddc  tgt_plrsv_margin
plrsv_margin(n,yall) = par_plrsv_margin(n,yall)

*_ POLICIES
parameters       target_co2_annual_y(*,*)  "(MtCO2/year) Cap on annual total system CO2 emissions in year-step (yall) and scenario (*)";
parameters       target_co2_longterm_y20(*)  "(MtCO2) Cap on cumulative total system CO2 emissions in scenario (*) along the planning horizon in 20-year timesteps";
$gdxIn   %input_co2target%
$loaddc  target_co2_annual_y
$loaddc  target_co2_longterm_y20

parameters       penalty_CO2ems(yall)  "(Thousands $/KtCO2) Tax penalty of CO2 emission"
                 credit_CINJECT(yall)  "(Thousands $/KtCO2) Tax credit of CO2 injection"
                 cap_annual_CO2ems(yall)  "(KtCO2/year) Cap on total system CO2 emissions in timestep (yall)"
                 cap_longterm_CO2ems  "(KtCO2) Cap on long-term total system CO2 emissions";
$ontext
penalty_CO2ems(yall) = par_years(yall,'penalty_CO2ems');
credit_CINJECT(yall) = par_years(yall,'credit_CINJECT');
$offtext
penalty_CO2ems(yall) = 0;
credit_CINJECT(yall) = 0;
cap_annual_CO2ems(yall) = 1000* target_co2_annual_y(yall,'%climatescenario%');
cap_longterm_CO2ems = 1000* target_co2_longterm_y20('%climatescenario%');

*_ ELECTRICITY GENERATION INFRASTRUCTURE
parameters       eg_typcap(eg)  "(MW) Typical capacity (size) of electricity generation technology type (eg)"
                 eg_lifetech(eg)  "(years) Lifetime of electricity generation technology type (eg)"
                 eg_capex(n,eg,yall)  "(Thousands US$/MW) Unit capital investment of electricity generation technology type (eg) in year (yall)"
                 eg_anncapex(n,eg,yall)  "(Thousands US$/MW) Annualized capital expenditure of electricity generation technology type (eg) in year (yall)"
                 eg_fom(n,eg,yall)  "(Thousands US$/MW) Fixed operation and maintenance costs of electricity generation technology type (eg) in year (yall)"
                 eg_vom(n,eg,yall)  "(Thousands US$/GWh) Variable operation and maintenance costs of electricity generation technology type (eg) in year (yall)"
                 eg_fuelmix(eg,f,yall)  "Maximum share of feedstock fuel commodity (f) in input feedstock mixture of electricity generation technology type (eg) in year (yall)"
                 eg_cfmax(eg)  "Maximum capacity factor of electricity generation technology type (eg)"
                 eg_cfmin(eg)  "Minimum capacity factor of electricity generation technology type (eg)"
                 eg_eef(eg)  "Rate of energy conversion efficiency of electricity generation technology type (eg)"
                 eg_ramprate(eg)  "(fraction/minute) Ramp rate of dispatchable electricity generation technology type (eg)"
                 eg_creditplrsv(eg)  "Fraction of capacity available for planning reserve credits of electricity generation technology type (eg)"
                 eg_surfacearea(eg)  "(Thousands m2/MW) Surface area per unit capacity of solar RES electricity generation technology type (eg)"
                 eg_landuse(eg)  "(Thousands m2/MW) Land use per unit capacity of electricity generation technology type (eg)"
                 eg_costCCX(n,eg,yall)  "(Thousands US$/KtCO2) Cost of CO2 capture of electricity generation technology type (eg) in year (yall)"
                 eg_rateCCX(eg)  "Rate of CO2 capture per CO2 emitted of electricity generation technology type (eg)"
;
eg_typcap(eg) = par_eg(eg,'typcap');
eg_lifetech(eg) = par_eg(eg,'life_tech');
eg_capex(n,eg,yall) = 1000* par_eg(eg,'capex')*(1+par_sit_eg(n,'mx_capex'))*par_years(yall,eg) /1000;
eg_anncapex(n,eg,yall) = 1000* par_eg(eg,'anncapex')*(1+par_sit_eg(n,'mx_capex'))*par_years(yall,eg) /1000;
eg_fom(n,eg,yall) = 1000* par_eg(eg,'fom') /1000;
eg_vom(n,eg,yall) = 1000* par_eg(eg,'vom') /1000;
eg_fuelmix(eg,f,yall) = par_eg(eg,f);
eg_cfmax(eg) = par_eg(eg,'cfmax');
eg_cfmin(eg) = par_eg(eg,'cfmin');
eg_eef(eg) = par_eg(eg,'eef_ely');
eg_ramprate(eg) = par_eg(eg,'ramprate');
eg_creditplrsv(eg) = par_eg(eg,'creditplrsv');
eg_surfacearea(eg) = par_eg(eg,'surfacearea') /1000;
eg_landuse(eg) = par_eg(eg,'m2_mw') /1000;
eg_costCCX(n,eg,yall) = 1000* par_eg(eg,'costCCX') /1000;
eg_rateCCX(eg) = par_eg(eg,'rateCCX');

*_ FUEL RESOURCE
parameters       p_FUEL(n,f,yall) "(Thousand US$/PJ) Price of energy commodity (f) at node (n) in year (yall)"

                 p_FUEL_LOCAL(n,f,yall) "(Thousand US$/PJ) Price of locally sourcing fuel (f) at node (n) in year (yall)"
                 p_FUEL_REGIONAL_nXr(n,r,f,yall) "(Thousand US$/PJ) Price of domestically sourcing fuel (f) from region (r) to node (n) in year (yall)"
                 p_FUEL_IMPORT_nXrimp(n,rimp,f,yall) "(Thousand US$/PJ) Price of importing fuel (f) from import regio n(rimp) to node (n) in year (yall)"
                 p_FUEL_REGIONAL_rXr(r,r,f,yall) "(Thousand US$/PJ) Price of domestically sourcing fuel (f) from region (r) to region (r) in year (yall)"
                 p_FUEL_IMPORT_rXrimp(r,rimp,f,yall) "(Thousand US$/PJ) Price of importing fuel (f) from import regio n(rimp) to region (r) in year (yall)"
;

p_FUEL(n,f,yall) = 10**6*par_fuel(f,'price_gj')/1000*(1+par_nodes(n,f))*par_years(yall,f);

p_FUEL_LOCAL(n,f,yall) = 10**6*par_fuel(f,'local_gj')/1000*(1+par_fuel_local(n,f))*par_years(yall,f);
p_FUEL_REGIONAL_nXr(n,r,f,yall) = 10**6*par_fuel(f,'regional_gj')/1000*(1+par_fuel_regional_nXr(n,r,f))*par_years(yall,f);
p_FUEL_IMPORT_nXrimp(n,rimp,f,yall) = 10**6*par_fuel(f,'import_gj')/1000*(1+par_fuel_import_nXrimp(n,rimp,f))*par_years(yall,f);
p_FUEL_REGIONAL_rXr(r,r,f,yall) = 10**6*par_fuel(f,'regional_gj')/1000*(1+par_fuel_regional_rXr(r,r,f))*par_years(yall,f);
p_FUEL_IMPORT_rXrimp(r,rimp,f,yall) = 10**6*par_fuel(f,'import_gj')/1000*(1+par_fuel_import_rXrimp(r,rimp,f))*par_years(yall,f);


parameters       fuel_reserve_local(n,f)  "(PJ) Reserved fuel resource at node"
                 fuel_production_local(n,f,yall)  "(PJ/year) Production of fuel resource at node";
* Reserves
fuel_reserve_local(n,'coa') = par_rsc_fuel_local(n,'RSV_COA')/10**6;
fuel_reserve_local(n,'oil') = par_rsc_fuel_local(n,'RSV_OIL')/10**6;
fuel_reserve_local(n,'gas') = par_rsc_fuel_local(n,'RSV_GAS')/10**6;
fuel_reserve_local(n,'nuc') = par_rsc_fuel_local(n,'RSV_NUC')/10**6;
* Production
fuel_production_local(n,f,yall) = par_rsc_fuel_local(n,f)/10**6;

parameters       fuel_reserve_regional(r,f)  "(PJ/year) Reserved fuel resource at region"
                 fuel_production_regional(r,f,yall)  "(PJ/year) Produced fuel resource at region";
* Reserves
fuel_reserve_regional(r,'coa') = par_rsc_fuel_regional(r,'RSV_COA')/10**6;
fuel_reserve_regional(r,'oil') = par_rsc_fuel_regional(r,'RSV_OIL')/10**6;
fuel_reserve_regional(r,'gas') = par_rsc_fuel_regional(r,'RSV_GAS')/10**6;
fuel_reserve_regional(r,'nuc') = par_rsc_fuel_regional(r,'RSV_NUC')/10**6;
* Production
fuel_production_regional(r,f,yall) = par_rsc_fuel_regional(r,f)/10**6;

*_ EMISSION FACTOR
parameters       emsf_CO2(f)  "(KtCO2/PJ) CO2 emissions factor of energy commodity (f)";
emsf_CO2(f) = 10**6*par_fuel(f,'emsf_CO2')/10**6;

*_RENEWABLE ENERGY SOURCE (RES)
parameters       potMW_geot(n)  "(MW) Potential generation capacity of Geothermal resource at node (n)"
                 potMW_hydrodam(n)  "(MW) Potential generation capacity of Large Hydropower, Dam resource at node (n)"
                 potMW_hydroror(n)  "(MW) Potential generation capacity of Micro-Hydropower, Run-off-river resource at node (n)"
                 cfdam(n)  "Resource-capacity factor of hydropower dam at node (n)"
                 cfror(n)  "Resource-capacity factor of hydropower run-off-river  at node (n)"
                 land_usw(n)  "(Thousands m2) Land availability for utilitily scale solar and wind power infrastructure at node (n)"
                 land_dgen(n)  "(Thousands m2) Land availability for distributed generation infrastructure at node (n)"
                 csp_dni(n)  "(GWh/Thousands m2) Long-term average daily direct normal irradiation (DNI) of CSP at node (n)"
                 upv_ghi(n)  "(GWh/Thousands m2) Long-term average daily global horizontal irradiation (GHI) of UPV at node (n)"
                 dpv_ghi(n)  "(GWh/Thousands m2) Long-term average daily global horizontal irradiation (GHI) of DPV at node (n)"
                 usw_windcf(n,eg)  "Resource-capacity factor of wind-turbine class (eg) of WINN at node (n)";
potMW_geot(n) = par_rsc_geot(n,'max_mw');
potMW_hydrodam(n) = par_rsc_hydro(n,'mw_dam');
potMW_hydroror(n) = par_rsc_hydro(n,'mw_ror');
cfdam(n) = par_rsc_hydro(n,'cf_dam');
cfror(n) = par_rsc_hydro(n,'cf_ror');
land_usw(n) = 1000* par_rsc_usw(n,'area_sqkm_usw');
land_dgen(n) = 1000* par_rsc_dgen(n,'area_sqkm_dgen');
csp_dni(n) = 1000* par_rsc_usw(n,'DNI') /1000000;
upv_ghi(n) = 1000* par_rsc_usw(n,'GHI') /1000000;
dpv_ghi(n) = 1000* par_rsc_dgen(n,'GHI') /1000000;
usw_windcf(n,'WINN-IEC1-S') = par_rsc_usw(n,'CF_IEC1');
usw_windcf(n,'WINN-IEC2-S') = par_rsc_usw(n,'CF_IEC2');
usw_windcf(n,'WINN-IEC3-XS') = par_rsc_usw(n,'CF_IEC3');

*_ MAXIMUM BUILD CAPACITY
parameters       maxbuild_mw_greg(n,greg)  "(MW) Limit on build capacity of electricity generation technology group (greg) at node (n)";
maxbuild_mw_greg(n,'largethermal') = par_sit_eg(n,'max_largethermal');
maxbuild_mw_greg(n,'engine') = par_sit_eg(n,'max_engine');
maxbuild_mw_greg(n,'bioreactor') = par_sit_eg(n,'max_bioreactor');

*_ ELECTRICITY TRANSMISSION INFRASTRUCTURE
*__ Transmission line
parameters       tre_typcap(kv)  "(MW) Typical capacity (size) of transmission line voltage class (kv)"
                 tre_capex_overland(n,n2,kv,yall)  "(Thousands US$/MW-km) Unit capital investment of transmission line voltage class (kv) overland"
                 tre_capex_oversea(n,n2,kv,yall)  "(Thousands US$/MW-km) Unit capital investment of transmission line voltage class (kv) oversea"
                 tre_anncapex_overland(n,n2,kv,yall)  "(Thousands US$/MW-km) Annualized capital expenditure of transmission line voltage class (kv) overland"
                 tre_anncapex_oversea(n,n2,kv,yall)  "(Thousands US$/MW-km) Annualized capital expenditure of transmission line voltage class (kv) oversea"
                 tre_losses_overland(n,n2,kv)  "Losses rate per km of transmission line voltage class (kv) overland"
                 tre_losses_oversea(n,n2,kv)  "Losses rate per km of transmission line voltage class (kv) oversea"
                 tre_cfmax(kv)  "Maximum capacity factor of technology type (kv)"
                 tre_cfmin(kv)  "Minimum capacity factor of technology type (kv)";
tre_typcap(kv) = par_tre(kv,'typcap');
tre_capex_overland(n,n2,kv,yall) = par_tre(kv,'capex')*(1+par_sit_tre(n,n2,'mxland_capex'))*par_years(yall,kv) /1000;
tre_capex_oversea(n,n2,kv,yall) = par_tre(kv,'capex')*(1+par_sit_tre(n,n2,'mxsea_capex'))*par_years(yall,kv) /1000;
tre_anncapex_overland(n,n2,kv,yall) = par_tre(kv,'anncapex')*(1+par_sit_tre(n,n2,'mxland_capex'))*par_years(yall,kv) /1000;
tre_anncapex_oversea(n,n2,kv,yall) = par_tre(kv,'anncapex')*(1+par_sit_tre(n,n2,'mxsea_capex'))*par_years(yall,kv) /1000;
tre_losses_overland(n,n2,kv) = par_tre(kv,'losses_10km')*(1+par_sit_tre(n,n2,'mxland_losses')) /10;
tre_losses_oversea(n,n2,kv) = par_tre(kv,'losses_10km')*(1+par_sit_tre(n,n2,'mxsea_losses')) /10;
tre_cfmax(kv) = par_tre(kv,'cfmax');
tre_cfmin(kv) = par_tre(kv,'cfmin');
*__ Transformer substation
parameters       sub_typcap(kv) "(MW) Typical capacity (size) of technology type (kv)"
                 sub_capex(n,kv,yall)  "(Thousands US$/MW) Unit capital investment of transformer substation class (kv)"
                 sub_anncapex(n,kv,yall)  "(Thousands US$/MW) Annualized capital expenditure of transformer substation class (kv)"
                 sub_losses(kv)  "Losses rate electricity voltage transformation of transformer substation class (kv)"
                 sub_cfmax(kv)  "Maximum capacity factor of technology type (kv)";
sub_typcap(kv) = par_sub(kv,'typcap');
sub_capex(n,kv,yall) = par_sub(kv,'capex')*(1+par_sit_sub(n,'mx_capex'))*par_years(yall,kv) /1000;
sub_anncapex(n,kv,yall) = par_sub(kv,'anncapex')*(1+par_sit_sub(n,'mx_capex'))*par_years(yall,kv) /1000;
sub_losses(kv) = par_sub(kv,'losses');
sub_cfmax(kv) = par_sub(kv,'cfmax');
*__ National aggregated values
parameters       dst_lineloss  "Distribution line losses"
                 dst_subloss  "Distribution substation ownuse"
                 nattre_losses  "Tranmission line losses"
                 nattre_ownuse  "Transmission line ownuse"
                 natsub_ownuse  "Transmission substation ownuse";
$gdxIn   %inputfile%
$loaddc  dst_lineloss
$loaddc  dst_subloss
$loaddc  nattre_losses
$loaddc  nattre_ownuse
$loaddc  natsub_ownuse

*_ CO2 TRANSPORT & STORAGE INFRASTRUCTURE
*__ CO2 TRANSPORT
parameters       trc_typcap(trc) "(MtCO2pa) Typical capacity (size) of technology type (trc)"
                 trc_capex_overland(n,n2,trc,yall) "(Thousands US$/MtCO2pa-km) Unit capital investment of CO2 transport technology type (trc) overland"
                 trc_capex_oversea(n,n2,trc,yall) "(Thousands US$/MtCO2pa-km) Unit capital investment of CO2 transport technology type (trc) oversea"
                 trc_annexpen_overland(n,n2,trc,yall) "(Thousands US$/MtCO2pa-km) Annual carrying costs (CAPEX+FOM) of CO2 transport technology type (trc) overland"
                 trc_annexpen_oversea(n,n2,trc,yall) "(Thousands US$/MtCO2pa-km) Annual carrying costs (CAPEX+FOM) of CO2 transport technology type (trc) oversea";
trc_typcap(trc) = par_trc(trc,'typcap');
trc_capex_overland(n,n2,trc,yall) = (par_trc(trc,'capex')*(1+par_sit_trc(n,n2,'mxland_capex'))*par_years(yall,trc) /1000 /10);
trc_capex_oversea(n,n2,trc,yall) = (par_trc(trc,'capex')*(1+par_sit_trc(n,n2,'mxsea_capex'))*par_years(yall,trc) /1000 /10);
trc_annexpen_overland(n,n2,trc,yall) = (par_trc(trc,'anncapex')*(1+par_sit_trc(n,n2,'mxland_capex'))*par_years(yall,trc) /1000 /10)  +  (par_trc(trc,'fom') /1000 /10);
trc_annexpen_oversea(n,n2,trc,yall) = (par_trc(trc,'anncapex')*(1+par_sit_trc(n,n2,'mxsea_capex'))*par_years(yall,trc) /1000 /10)  +  (par_trc(trc,'fom') /1000 /10);

*__ CO2 STORAGE
parameters       maxroom_CSTORAGE(n)  "(KtCO2) Initial CO2 storage potential at node (n)"
                 maxrate_CINJECT(n)  "(KtCO2/year) Maximum CO2 injection rate at node (n)"
                 ucost_CINJECT(n,yall)  "(Thousands US$/KtCO2) CO2 injection cost at node (n)";
maxroom_CSTORAGE(n) = 1000* par_csink(n,'room_co2storage');
maxrate_CINJECT(n) = 1000* par_csink(n,'max_co2inject');
ucost_CINJECT(n,yall) = 1000* par_csink(n,'ucost_co2inject') /1000;

*_ STOCK AND PRESCRIBED INFRASTRUCTURE
parameters       eg_stkcap(n,eg,yall)  "(MW) Capacity of stock electricity generation technology type (eg) at node (n) that was built in year (v)"
                 sub_stkcap(n,kv)  "(MW) Capacity of stock electricity transformer-substation voltage class(kv) at node (n) in year (yall)"
                 tre_stkcap(n,n2,kv)  "(MW) Capacity of stock electricity transmission voltage class (kv) from node (n) to another node (n2)"
                 trc_stkcap(n,n2,trc)  "(KtCO2/year) Capacity of stock CO2 transport technology type (trc) in from node (n) to another node (n2)"
                 eg_codcap(n,eg,yall)  "(MW) Capacity of planned or under-construction electricity generation technology type (eg) at node (n) that was built in year (v)"
                 tre_codcap(n,n2,kv,yall)  "(MW) Capacity of planned electricity transmission voltage class (kv) from node (n) to another node (n2) in year (yall)"
;
eg_stkcap(n,eg,yall) = par_stk_eg(n,eg,yall,'stk_MW');
sub_stkcap(n,kv) = par_stk_sub(n,kv,'stk_MW');
tre_stkcap(n,n2,kv) = par_stk_tre(n,n2,kv,'stk_MW');
*trc_stkcap(n,n2,trc) = par_stk_trc(n,n2,kv,'stk_Mtpa');
trc_stkcap(n,n2,trc) = 0;
eg_codcap(n,eg,yall) = par_cod_eg(n,eg,yall,'cod_MW');
tre_codcap(n,n2,kv,yall) = par_cod_tre(n,n2,kv,yall,'cod_MW');



*===============================================================================
*# VARIABLES
*===============================================================================
*# COSTS
free variables           Z  "(Billions $) Cumulative total system costs along the modelled years"
                         COST_System(yall)  "(Millions $/year) Annual cost of the total system in year (yall)";
positive variables       COST_egANNCAPEX(n,eg,v,yall)  "(Thousands $/year) Annualized capital expenditures of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
                         COST_egFOM(n,eg,v,yall)  "(Thousands $/year) Annual cost of fixed operation and maintenance costs of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
                         COST_egVOM(n,eg,v,yall)  "(Thousands $/year) Annual cost of variable operation and maintenance costs of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
$ontext
                         COST_egFUEL(n,eg,v,yall)  "(Thousands $/year) Annual cost of fuel for electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
$offtext
*$ontext
positive variables       COST_FUEL_LOCAL(n,f,yall)  "(Thousands $/year) Annual cost of locally sourcing fuel (f) at node (n) in year (yall)"
                         COST_FUEL_REGIONAL_nXr(n,r,f,yall)  "(Thousands $/year) Annual cost of regionally sourcing fuel (f) from domestic region (r) to node (n) in year (yall)"
                         COST_FUEL_IMPORT_nXrimp(n,rimp,f,yall)  "(Thousands $/year) Annual cost of importing fuel (f) from import region (rimp) to node (n) in year (yall)"
                         COST_FUEL_REGIONAL_rXr(r,r2,f,yall)  "(Thousands $/year) Annual cost of regionally sourcing fuel (f) from domestic region (r2) to region (r) in year (yall)"
                         COST_FUEL_IMPORT_rXrimp(r,rimp,f,yall)  "(Thousands $/year) Annual cost of importing fuel (f) from import region (rimp) to region (r) in year (yall)"
*$offtext
                         COST_sub(n,kv,yall)  "(Thousands $/year) Annual cost of transformer-substation voltage class (kv) that was built in year (v) at node (n) in year (yall)"
                         COST_tre(n,n2,kv,yall)  "(Thousands $/year) Annual cost of electricity transmission voltage class (kv)  that was built in year (v) from node (n) to another node (n2) in year (yall)"
                         COST_trc(n,n2,trc,yall)  "(Thousands $/year) Annual cost of CO2 transport technology type (trc) from node (n) to another node (n2) in year (yall)"
                         COST_CINJECT(n,yall)  "(Thousands $/year) Annual cost of CO2 injection at node (n) in year (yall)"
*$ontext
                         COST_egCTAX(n,eg,v,yall)  "(Thousands $/year) Annual cost of CO2 emissiosn penalty of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
                         REVENUE_CINJECT(n,yall)  "(Thousands $/year) Annual revenue of CO2 injection credit at node (n) in year (yall)"
*$offtext
;

*SUPPLY-DEMAND
positive variables       S_ely(n,kv,yall)  "(GWh/year) Supply of electricity at node (n) of voltage class (kv) in year (yall)"
                         S_plrsv(n,kv,yall)  "(GWh/year) Supply of planning reserve capacity at node (n) of voltage class (kv) in year (yall)"
                         S_fuel_Xn(n,f,yall)  "(GJ/year) Supply of fuel (f) at node (n) in year (yall)"
                         S_fuel_Xr(r,f,yall)  "(GJ/year) Supply of fuel (f) at region (r) in year (yall)"
;
*$ontext
*# FUELS
positive variables       FUEL_LOCAL(n,f,yall)  "(PJ/year) Local sourced fuel (f) at node (n) in year (yall)"
                         FUEL_REGIONAL_nXr(n,r,f,yall)  "(PJ/year) Regionally sourced fuel (f) from domestic region (r) to node (n) in year (yall)"
                         FUEL_IMPORT_nXrimp(n,rimp,f,yall)  "(PJ/year) Import of fuel (f) from import region (rimp) to node (n) in year (yall)"
                         FUEL_REGIONAL_rXr(r,r2,f,yall)  "(PJ/year) Regionally sourced fuel (f) from domestic region (r2) to region (r) in year (yall)"
                         FUEL_IMPORT_rXrimp(r,rimp,f,yall)  "(PJ/year) Import of fuel (f) from import region (rimp) to region (r) in year (yall)"
*$offtext

*# ELECTRICITY GENERATION
integer variables        egNEWi(n,eg,v)  "(integer) Number of new addition electricity generation infrastructure (eg) at node (n) that was built in year (v) to account for integer variables";
positive variables       egNEWc(n,eg,v)  "(MW) Capacity of new addition electricity generation infrastructure (eg) at node (n) that was built in year (v) to account for continuous variables"
                         egNEW(n,eg,v)  "(MW) Capacity of new addition electricity generation infrastructure (eg) at node (n) that was built in year (v) to account for all variables"
                         egCAP(n,eg,v,yall)  "(MW) Capacity of installed electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egCAP_plrsv(n,eg,v,yall)    "(MW) Reserved capacity of installed electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egRET(n,eg,v,yall)  "(MW) Retired capacity of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egOUT_ely(n,eg,v,yall)  "(GWh/year) Annual amount of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egINMIX(n,eg,v,yall)  "(GWh/year) Annual energy input mixture of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egFUEL(n,eg,v,f,yall)  "(PJ/year) Annual consumption of fuel (f) of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egCO2ems(n,eg,v,yall)  "(KtCO2/year) Annual CO2 emissions of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egCO2bio(n,eg,v,yall)  "(KtCO2/year) Annual CO2 emissions from burning of biomass of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egCCX(n,eg,v,yall)  "(KtCO2/year) Annual amount of CO2 captured of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
;
*# TRANSFORMER-SUBSTATION
positive variables       subNEW(n,kv,yall)  "(MW) Capacity of new addition transformer-substation infrastructure (sub/kv)  at node (n) in year (yall)"
                         subCAP(n,kv,yall)  "(MW) Capacity of installed transformer-substation infrastructure (sub/kv) at node (n) in year (yall)";
positive variables       subVUP_ely(n,kv,kv2,yall)  "(GWh/year) Annual electricity transformed from voltage class (kv) to higher voltage class (kv2>kv) at node (n) in year (yall)"
                         subVDO_ely(n,kv,kv2,yall)  "(GWh/year) Annual electricity transformed from voltage class (kv) to lower voltage class (kv2<kv) at node (n) in year (yall)"
                         subVUP_plrsv(n,kv,kv2,yall)  "(MW) Planning reserve capacity transformed from voltage class (kv) to higher voltage class (kv2>kv) by transformer-substation technology type (sub) at node (n) in year (yall)"
                         subVDO_plrsv(n,kv,kv2,yall)  "(MW) Planning reserve capacity transformed from voltage class (kv) to lower voltage class (kv2<kv) by transformer-substation technology type (sub) at node (n) in year (yall)"
;
*# TRANSMISSION LINE
integer variables        treNEWi(n,n2,kv,yall)  "(integer) Number of new addition transmission line type (tre/kv) from node (n) to another node (n2) in year (yall) to account for integer variables";
positive variables       treNEWc(n,n2,kv,yall)  "(MW) Capacity of new addition transmission line type (tre/kv) from node (n) to another node (n2) in year (yall) to account for continuous variables"
                         treNEW(n,n2,kv,yall)  "(MW) Capacity of new addition transmission line type (tre/kv) from node (n) to another node (n2) in year (yall) to account for all variables"
                         treCAP(n,n2,kv,yall)  "(MW) Capacity of installed electricity transmission line type (tre/kv) from node (n) to another node (n2) in year (yall)"
                         treCAPBOTH(n,n2,kv,yall)   "(MW) Capacity of installed electricity transmission line type (tre/kv) in both direction (n,n2) and (n,n2) in year (yall)";
positive variables       treFLOW_ely(n,n2,kv,yall)  "(GWh/year) Annual flow of electricity transmitted by transmission line type (tre/kv) from node (n) to another node (n2) in year (yall)"
                         treFLOW_plrsv(n,n2,kv,yall)  "(MW) Planning reserve capacity transmitted by transmission line type (tre/kv) from node (n) to another node (n2) in year (yall)"
;
*CO2 TRANSPORT AND STORAGE
integer variables        trcNEWi(n,n2,trc,yall)  "(integer) Number of new addition CO2 transport infrastructure (trc) from node (n) to another node (n2) in year (yall) to account for integer variables";
positive variables       trcNEWc(n,n2,trc,yall)  "(KtCO2/year) capacity of new addition CO2 transport infrastructure (trc) from node (n) to another node (n2) in year (yall) to account for continuous variables"
                         trcNEW(n,n2,trc,yall)  "(KtCO2/year) capacity of new addition CO2 transport infrastructure (trc) from node (n) to another node (n2) in year (yall) to account for all variables"
                         trcCAP(n,n2,trc,yall)  "(KtCO2/year) Installed capacity of CO2 transport infrastructure (trc) from node (n) to another node (n2) in year (yall)"
                         trcCAPBOTH(n,n2,trc,yall)  "(KtCO2/year) Installed capacity of CO2 transport technology type (trc) for both direction (n,n2) and (n,n2) in year (yall)";
positive variables       trcFLOW_CO2(n,n2,trc,yall)  "(KtCO2/year) Flow of CO2 in CO2 transport infrastructure (trc) from node (n) to another node (n2) in year (yall)";
positive variables       CINJECT(n,yall)  "(KtCO2/year) Flow of CO2 injected at node (n) in year (yall)"
;



*===============================================================================
*# COST EQUATIONS
*===============================================================================
*_ CUMULATIVE TOTAL SYSTEM COSTS
equation  eq_Z  "Cumulative total system costs along the modelled years";
eq_Z..   Z*1000  =e=  sum{(y),COST_System(y)};

*_ ANNUAL TOTAL SYSTEM COSTS
equation  EQ_COST_System(yall)  "Annual total system costs";
EQ_COST_System(y)..
COST_System(y)*1000  =e=  sum{(n,eg,v)$[sit_eg(n,eg) and (v.val <= y.val)], COST_egANNCAPEX(n,eg,v,y)}
                          + sum{(n,eg,v)$[sit_eg(n,eg) and (v.val <= y.val)], COST_egFOM(n,eg,v,y)}
                          + sum{(n,eg,v)$[sit_eg(n,eg) and (v.val <= y.val)], COST_egVOM(n,eg,v,y)}
$ontext
                          + sum{(n,eg,v)$[sit_eg(n,eg) and eg_firing(eg) and (v.val <= y.val)], COST_egFUEL(n,eg,v,y)}
$offtext
                          + sum{(n,f)$[par_fuel_local(n,f)], COST_FUEL_LOCAL(n,f,y)}
$ontext
* Supply-demand balancing by NODE
                          + sum{(n,r,f)$[par_fuel_regional_nXr(n,r,f)], COST_FUEL_REGIONAL_nXr(n,r,f,y)}
                          + sum{(n,rimp,f)$[par_fuel_import_nXrimp(n,rimp,f)], COST_FUEL_IMPORT_nXrimp(n,rimp,f,y)}
$offtext
*$ontext
* Supply-demand balancing by REGION
                          + sum{(r,r2,f)$[par_fuel_regional_rXr(r,r2,f)], COST_FUEL_REGIONAL_rXr(r,r2,f,y)}
                          + sum{(r,rimp,f)$[par_fuel_import_rXrimp(r,rimp,f)], COST_FUEL_IMPORT_rXrimp(r,rimp,f,y)}
*$offtext

                          + sum{(n,kv)$[sit_sub(n,kv)], COST_sub(n,kv,y)}
                          + sum{(n,n2,kv)$[sit_tre(n,n2,kv)], COST_tre(n,n2,kv,y)}

                          + sum{(n,n2,trc)$[sit_trc(n,n2,trc)], COST_trc(n,n2,trc,y)}
                          + sum{(n)$[csink(n)], COST_CINJECT(n,y)}
*$ontext
                          + sum{(n,eg,v)$[sit_eg(n,eg) and eg_firing(eg) and (v.val <= y.val)], COST_egCTAX(n,eg,v,y)}
                          - sum{(n)$[csink(n)], REVENUE_CINJECT(n,y)}
*$offtext
;

*_ COST OF ELECTRICITY GENERATION INVESTMENT
equation  EQ_COST_egANNCAPEX(n,eg,v,yall)  "Annual cost of electricity generation investment annuity";
EQ_COST_egANNCAPEX(n,eg,v,y)$[sit_eg(n,eg) and v.val <= y.val]..
COST_egANNCAPEX(n,eg,v,y)  =e=  egCAP(n,eg,v,y)*eg_anncapex(n,eg,v);

*_ COST OF ELECTRICITY GENERATION FOM
equation  EQ_COST_egFOM(n,eg,v,yall)  "Annual cost of electricity generation fixed operation and maintenance";
EQ_COST_egFOM(n,eg,v,y)$[sit_eg(n,eg) and v.val <= y.val]..
COST_egFOM(n,eg,v,y)  =e=  egCAP(n,eg,v,y)*eg_fom(n,eg,y);

*_ COST OF ELECTRICITY GENERATION VOM
equation  EQ_COST_egVOM(n,eg,v,yall)  "Annual cost of electricity generation variable operation and maintenance";
EQ_COST_egVOM(n,eg,v,y)$[sit_eg(n,eg) and v.val <= y.val]..
COST_egVOM(n,eg,v,y)  =e=  egOUT_ely(n,eg,v,y)*eg_vom(n,eg,y);


$ontext
*_ COST OF ELECTRICITY GENERATION FUEL
*__ Price delivered at power plant gate
equation  EQ_COST_egFUEL(n,eg,v,yall)  "Annual cost of fuel for electricity generation input";
EQ_COST_egFUEL(n,eg,v,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..   COST_egFUEL(n,eg,v,y) =e= sum{(f)$[eg_fuelmix(eg,f,y)], egFUEL(n,eg,v,f,y)*price_FUEL(n,f,y)};
$offtext


*$ontext
*_ COST OF FUEL LOCAL SOURCED
equation  EQ_COST_FUEL_LOCAL(n,f,yall)  "Annual cost of fuel locally sourced";
EQ_COST_FUEL_LOCAL(n,f,y)$[par_fuel_local(n,f)]..
COST_FUEL_LOCAL(n,f,y)  =e=  FUEL_LOCAL(n,f,y)*p_FUEL_LOCAL(n,f,y);
*$offtext


$ontext
* Supply-demand balancing by NODE
*_ COST OF FUEL REGIONAL SOURCED
equation  EQ_COST_FUEL_REGIONAL_nXr(n,r,f,yall)  "Annual cost of fuel regionally sourced";
EQ_COST_FUEL_REGIONAL_nXr(n,r,f,y)$[par_fuel_regional_nXr(n,r,f)]..
COST_FUEL_REGIONAL_nXr(n,r,f,y)  =e=  FUEL_REGIONAL_nXr(n,r,f,y)*p_FUEL_REGIONAL_nXr(n,r,f,y);

*_ COST OF FUEL IMPORT SOURCED
equation  EQ_COST_FUEL_IMPORT_nXrimp(n,rimp,f,yall)  "Annual cost of fuel imports";
EQ_COST_FUEL_IMPORT_nXrimp(n,rimp,f,y)$[par_fuel_import_nXrimp(n,rimp,f)]..
COST_FUEL_IMPORT_nXrimp(n,rimp,f,y)  =e=  FUEL_IMPORT_nXrimp(n,rimp,f,y)*p_FUEL_IMPORT_nXrimp(n,rimp,f,y);
$offtext


*$ontext
* Supply-demand balancing by REGION
*_ COST OF FUEL REGIONAL SOURCED
equation  EQ_COST_FUEL_REGIONAL_rXr(r,r2,f,yall)  "Annual cost of fuel regionally sourced";
EQ_COST_FUEL_REGIONAL_rXr(r,r2,f,y)$[par_fuel_regional_rXr(r,r2,f)]..
COST_FUEL_REGIONAL_rXr(r,r2,f,y)  =e=  FUEL_REGIONAL_rXr(r,r2,f,y)*p_FUEL_REGIONAL_rXr(r,r2,f,y);

*_ COST OF FUEL IMPORT SOURCED
equation  EQ_COST_FUEL_IMPORT_rXrimp(r,rimp,f,yall)  "Annual cost of fuel imports";
EQ_COST_FUEL_IMPORT_rXrimp(r,rimp,f,y)$[par_fuel_import_rXrimp(r,rimp,f)]..
COST_FUEL_IMPORT_rXrimp(r,rimp,f,y)  =e=  FUEL_IMPORT_rXrimp(r,rimp,f,y)*p_FUEL_IMPORT_rXrimp(r,rimp,f,y);
*$offtext



*_ COSTS OF TRANSMISSION GRID INFRASTRUCTURE
equation  EQ_COST_sub(n,kv,yall)  "Annual cost of transformer-substation infrastructure";
EQ_COST_sub(n,kv,y)$[sit_sub(n,kv)]..
COST_sub(n,kv,y)  =e=  subCAP(n,kv,y)*sub_anncapex(n,kv,y);

equation  EQ_COST_tre(n,n2,kv,yall)  "Annual cost of transmission line infrastructure";
EQ_COST_tre(n,n2,kv,y)$[sit_tre(n,n2,kv)]..
COST_tre(n,n2,kv,y)  =e=  treCAP(n,n2,kv,y)*((distance_onshore_tre(n,n2)*tre_anncapex_overland(n,n2,kv,y))
                          +(distance_offshore_tre(n,n2)*tre_anncapex_oversea(n,n2,kv,y)));

*_ COSTS OF CO2 TRANSPORT AND STORAGE
equation  EQ_COST_trc(n,n2,trc,yall)  "Annual cost of CO2 transport infrastructure";
EQ_COST_trc(n,n2,trc,y)$[sit_trc(n,n2,trc)]..
COST_trc(n,n2,trc,y)  =e=  trcCAP(n,n2,trc,y)*(
                           (distance_onshore_trc(n,n2)*trc_annexpen_overland(n,n2,trc,y))
                           +(distance_offshore_trc(n,n2)*trc_annexpen_oversea(n,n2,trc,y))
                           );

equation  EQ_COST_CINJECT(n,yall)  "Annual cost of CO2 injection and storage";
EQ_COST_CINJECT(n,y)$[csink(n)]..
COST_CINJECT(n,y)  =e=  CINJECT(n,y)*ucost_CINJECT(n,y);

*_ PRICE INCENTIVES
*$ontext
equation  EQ_COST_egCTAX(n,eg,v,yall)  "Annual cost of electricity generation CO2 tax penalty";
EQ_COST_egCTAX(n,eg,v,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..
COST_egCTAX(n,eg,v,y)
=e=
(egCO2ems(n,eg,v,y)-egCO2bio(n,eg,v,y))*(1-eg_rateCCX(eg))*penalty_CO2ems(y);

equation  EQ_REVENUE_CINJECT(n,yall)  "Annual revenue of CO2 injection";
EQ_REVENUE_CINJECT(n,y)$[csink(n)]..
REVENUE_CINJECT(n,y)
=e=
(CINJECT(n,y))*credit_CINJECT(y);
*$offtext



*===============================================================================
*# POLICY TARGETS
*===============================================================================
*_ CAP ON CO2 EMISSIONS
$ontext
equation  EQ_cap_annual_CO2ems(yall)  "Cap on annual CO2 emissions";
EQ_cap_annual_CO2ems(y)$[cap_annual_CO2ems(y)]..
cap_annual_CO2ems(y)  =g=  sum{(n,eg,v)$[sit_eg(n,eg) and eg_firing(eg) and (v.val<=y.val)], egCO2ems(n,eg,v,y)}
                           - sum{(n,eg,v)$[sit_eg(n,eg) and eg_firing(eg) and (v.val<=y.val)], egCO2bio(n,eg,v,y)}
                           - sum{(n,eg,v)$[sit_eg(n,eg) and eg_rateCCX(eg) and (v.val<=y.val)], egCCX(n,eg,v,y)$[eg_rateCCX(eg)]};
$offtext
*$ontext
equation  EQ_cap_longterm_CO2ems  "Cap on long-term cumulative CO2 emissions";
EQ_cap_longterm_CO2ems..
cap_longterm_CO2ems  =g=  sum{(y),sum{(n,eg,v)$[sit_eg(n,eg) and eg_firing(eg) and (v.val<=y.val)], egCO2ems(n,eg,v,y)}
                          - sum{(n,eg,v)$[sit_eg(n,eg) and eg_firing(eg) and (v.val<=y.val)], egCO2bio(n,eg,v,y)}
                          - sum{(n,eg,v)$[sit_eg(n,eg) and eg_rateCCX(eg) and (v.val<=y.val)], egCCX(n,eg,v,y)$[eg_rateCCX(eg)]}};
*$offtext



*===============================================================================
*# ELECTRICITY BALANCE AND DEMAND FULFILEMENT
*===============================================================================
*_ ELECTRICITY DEMAND FULFILMENT
equation  EQ_DFULFILL_ely(n,kv,yall)  "Electricity demand fulfillment";
EQ_DFULFILL_ely(n,kv,y)..
* Supply at node
S_ely(n,kv,y)$[val_kv(kv) eq 30]
=g=
* Demand at node
D_ely(n,y)$[val_kv(kv) eq 30]*(1+dst_subloss)*(1+dst_lineloss)
;

*_ ELECTRICITY BALANCE
equation  EQ_SDBALANCE_ely(n,kv,yall)  "Electricity supply and demand balance at node";
EQ_SDBALANCE_ely(n,kv,y)..
* Supply at node
S_ely(n,kv,y)$[val_kv(kv) eq 30]  =e=
* Generated at node
sum{(eg,v)$[sit_eg(n,eg) and v.val <= y.val],  egOUT_ely(n,eg,v,y)}$[val_kv(kv) eq 30]
* Transmitted in and out node
+ sum{(n2)$[sit_tre(n2,n,kv)], treFLOW_ely(n2,n,kv,y)*(1-(tre_losses_overland(n2,n,kv)*distance_onshore_tre(n2,n)))*(1-(tre_losses_oversea(n2,n,kv)*distance_offshore_tre(n2,n)))}
- sum{(n2)$[sit_tre(n,n2,kv)], treFLOW_ely(n,n2,kv,y)}
* Voltage class step up at node
+ sum{(kv2)$[sit_sub(n,kv2) and sit_sub(n,kv) and val_kv(kv2) < val_kv(kv)], subVUP_ely(n,kv2,kv,y)}
- sum{(kv2)$[sit_sub(n,kv) and sit_sub(n,kv2) and val_kv(kv2) > val_kv(kv)], subVUP_ely(n,kv,kv2,y)}
* Voltage class step down at node
+ sum{(kv2)$[sit_sub(n,kv2) and sit_sub(n,kv) and val_kv(kv2) > val_kv(kv)], subVDO_ely(n,kv2,kv,y)*(1-sub_losses(kv)$[val_kv(kv) eq 30])}
- sum{(kv2)$[sit_sub(n,kv) and sit_sub(n,kv2) and val_kv(kv2) < val_kv(kv)], subVDO_ely(n,kv,kv2,y)*(1-sub_losses(kv)$[val_kv(kv2) eq 30])};

*_ PLANNING RESERVES REQUIREMENTS
equation  EQ_DFULFILL_plrsv(n,kv,yall)  "Planning reserve demand fulfillment";
EQ_DFULFILL_plrsv(n,kv,y)..
* Supply at node
S_plrsv(n,kv,y)$[val_kv(kv) eq 30]
=g=
* Demand at node
(1+plrsv_margin(n,y))*Dpeak_ely(n,y)$[val_kv(kv) eq 30]*(1+dst_subloss)*(1+dst_lineloss);

* PLANNING RESERVE CAPACITY BALANCE
equation  EQ_SDBALANCE_plrsv(n,kv,yall)  "Planning reserve supply and demand balance at node";
EQ_SDBALANCE_plrsv(n,kv,y)..
* Supply at node
S_plrsv(n,kv,y)$[val_kv(kv) eq 30]  =e=
* Reserved at
sum{(eg,v)$[sit_eg(n,eg) and eg_creditplrsv(eg) and v.val <= y.val], egCAP_plrsv(n,eg,v,y)}$[val_kv(kv) eq 30]
* Transmitted in and out
+ sum{(n2)$[sit_tre(n2,n,kv)], treFLOW_plrsv(n2,n,kv,y)*(1-(tre_losses_overland(n2,n,kv)*distance_onshore_tre(n2,n)))*(1-(tre_losses_oversea(n2,n,kv)*distance_offshore_tre(n2,n)))}
- sum{(n2)$[sit_tre(n,n2,kv)], treFLOW_plrsv(n,n2,kv,y)}
* Voltage class step-up
+ sum{(kv2)$[sit_sub(n,kv2) and sit_sub(n,kv) and val_kv(kv2) < val_kv(kv)], subVUP_plrsv(n,kv2,kv,y)}
- sum{(kv2)$[sit_sub(n,kv) and sit_sub(n,kv2) and val_kv(kv2) > val_kv(kv)], subVUP_plrsv(n,kv,kv2,y)}
* Voltage class step-down
+ sum{(kv2)$[sit_sub(n,kv2) and sit_sub(n,kv) and val_kv(kv2) > val_kv(kv)], subVDO_plrsv(n,kv2,kv,y)*(1-sub_losses(kv)$[val_kv(kv) eq 30])}
- sum{(kv2)$[sit_sub(n,kv) and sit_sub(n,kv2) and val_kv(kv2) < val_kv(kv)], subVDO_plrsv(n,kv,kv2,y)*(1-sub_losses(kv)$[val_kv(kv2) eq 30])};

* PLANNING RESERVE CAPACITY CREDIT
equation  EQ_egCAP_plrsv(n,eg,v,yall)  "Planning reserve credit";
EQ_egCAP_plrsv(n,eg,v,y)$[sit_eg(n,eg)]..
egCAP_plrsv(n,eg,v,y)  =l=  egCAP(n,eg,v,y)*eg_creditplrsv(eg);



*===============================================================================
*# GRID INFRASTRUCTURE FLOW CAPACITY
*===============================================================================
*_ TRANSMISSION LINE
*__ NET TRANSFER CAPACITY
equation  EQ_treCAPBOTH(n,n2,kv,yall)  "Intalled transfer capacity of transmission line for both directions";
EQ_treCAPBOTH(n,n2,kv,y)$[sit_tre(n,n2,kv) or sit_tre(n2,n,kv)]..
* Net transfer capacity are combined from built capacities of both directions
treCAPBOTH(n,n2,kv,y)  =e=  treCAP(n,n2,kv,y) + treCAP(n2,n,kv,y);

*__ CAPACITY FACTOR
equation  EQ_trecfmax_ely(n,n2,kv,yall)  "Transmission line maximum capacity factor for electricity and operating reserves flows";
EQ_trecfmax_ely(n,n2,kv,y)$[sit_tre(n,n2,kv) or sit_tre(n2,n,kv)]..
fullhours*treCAPBOTH(n,n2,kv,y)*tre_cfmax(kv)  =g=  treFLOW_ely(n,n2,kv,y) *1000;
$ontext
equation  EQ_trecfmin_ely(n,n2,kv,yall)  "Transmission line minimum capacity factor for electricity and operating reserves flows";
EQ_trecfmin_ely(n,n2,kv,y)$[sit_tre(n,n2,kv) or sit_tre(n2,n,kv)]..
fullhours*treCAPBOTH(n,n2,kv,y)*tre_cfmin(kv)  =l=  treFLOW_ely(n,n2,kv,y) *1000;
$offtext
equation  EQ_trecfmax_plrsv(n,n2,kv,yall)  "Transmission line maximum capacity factor for planning reserve flows";
EQ_trecfmax_plrsv(n,n2,kv,y)$[sit_tre(n,n2,kv) or sit_tre(n2,n,kv)]..
treCAPBOTH(n,n2,kv,y)*tre_cfmax(kv)  =g=  treFLOW_plrsv(n,n2,kv,y);
$ontext
equation  EQ_trecfmin_plrsv(n,n2,kv,yall)  "Transmission line minimum capacity factor for planning reserve flows";
EQ_trecfmin_plrsv(n,n2,kv,y)$[sit_tre(n,n2,kv) or sit_tre(n2,n,kv)]..
treCAPBOTH(n,n2,kv,y)*tre_cfmin(kv)  =l=  treFLOW_plrsv(n,n2,kv,y);
$offtext

*_ TRANSFORMER SUBSTATION
*__ CAPACITY FACTOR
equation  EQ_subcfmax_ely_vup(n,kv,yall)  "Transformation maximum capacity factor for electricity voltage transformation up";
EQ_subcfmax_ely_vup(n,kv,y)$[sit_sub(n,kv) and val_kv(kv) > 30]..
fullhours*subCAP(n,kv,y)*sub_cfmax(kv)  =g=  sum{(kv2)$[(val_kv(kv) > val_kv(kv2))], subVUP_ely(n,kv2,kv,y) *1000};

equation  EQ_subcfmax_ely_vdo(n,kv,yall)  "Transformation maximum capacity factor for electricity voltage transformation down";
EQ_subcfmax_ely_vdo(n,kv,y)$[sit_sub(n,kv) and val_kv(kv) > 30]..
fullhours*subCAP(n,kv,y)*sub_cfmax(kv)  =g=  sum{(kv2)$[(val_kv(kv) > val_kv(kv2))], subVDO_ely(n,kv,kv2,y) *1000};

equation  EQ_subcfmax_plrsv_vup(n,kv,yall)  "Transformation maximum capacity factor for planning reserve voltage transformation up";
EQ_subcfmax_plrsv_vup(n,kv,y)$[sit_sub(n,kv) and val_kv(kv) > 30]..
subCAP(n,kv,y)*sub_cfmax(kv)  =g=  sum{(kv2)$[val_kv(kv) > val_kv(kv2)], subVUP_plrsv(n,kv2,kv,y)};

equation  EQ_subcfmax_plrsv_vdo(n,kv,yall)  "Transformation maximum capacity factor for planning reserve voltage transformation down";
EQ_subcfmax_plrsv_vdo(n,kv,y)$[sit_sub(n,kv) and val_kv(kv) > 30]..
subCAP(n,kv,y)*sub_cfmax(kv)  =g=  sum{(kv2)$[val_kv(kv) > val_kv(kv2)], subVDO_plrsv(n,kv,kv2,y)};

equation  EQ_subcfmax_mv(n,kv,yall)  "Capacity requirement of MV transformer-substation for short-distance transmission";
EQ_subcfmax_mv(n,kv,y)$[sit_sub(n,kv) and val_kv(kv) = 30]..
subCAP(n,kv,y)*sub_cfmax(kv)  =g=  sum{(n2)$[sit_tre(n,n2,kv)], treCAP(n,n2,kv,y)} + sum{(n2)$[sit_tre(n2,n,kv)], treCAP(n2,n,kv,y)};
* MV substation capacity covers all installed inbound- and outbound-transmission capacities



*===============================================================================
*# RESOURCE BALANCE AND POTENTIAL AVAILABILITY
*===============================================================================
*_ FUEL RESOURCE BALANCE
$ontext
* Supply-demand balancing by NODE
equation  EQ_fuel_demand_fulfilment_Xn(n,f,yall)  "Fuel demand fulfilment at node";
EQ_fuel_demand_fulfilment_Xn(n,f,y)..
S_fuel_Xn(n,f,y)  =g=
* Input fuel for electricity generation
sum{(eg,v)$[sit_eg(n,eg) and eg_fuelmix(eg,f,y) and not eg_bioreactor(eg)], egFUEL(n,eg,v,f,y)}

equation  EQ_fuel_balance_Xn(n,f,yall)  "Fuel supply at node";
EQ_fuel_balance_Xn(n,f,y)..
S_fuel_Xn(n,f,y)  =e=
* Locally sourced
FUEL_LOCAL(n,f,y)$[par_fuel_local(n,f)]
* Domestically sourced from other region
+ sum{(r)$[trade_nXr(n,r) and par_fuel_regional_nXr(n,r,f)], FUEL_REGIONAL_nXr(n,r,f,y)}
* Imported
+ sum{(rimp)$[trade_nXrimp(n,rimp) and par_fuel_import_nXrimp(n,rimp,f)], FUEL_IMPORT_nXrimp(n,rimp,f,y)}
;
$offtext

*$ontext
* Supply-demand balancing by REGION
equation  EQ_fuel_demand_fulfilment(r,f,yall)  "Fuel demand fulfilment at region";
EQ_fuel_demand_fulfilment(r,f,y)..
S_fuel_Xr(r,f,y)  =g=
* Input fuel for electricity generation
sum{(n)$[map_nXr(n,r)],
* Nodal consumption
         sum{(eg,v)$[sit_eg(n,eg) and eg_fuelmix(eg,f,y) and not eg_bioreactor(eg)], egFUEL(n,eg,v,f,y)}
* Locally sourced
         - FUEL_LOCAL(n,f,y)$[par_fuel_local(n,f)]};

equation  EQ_fuel_balance(r,f,yall)  "Fuel supply at region";
EQ_fuel_balance(r,f,y)..
S_fuel_Xr(r,f,y)  =e=
* Domestically sourced from other region
+ sum{(r2)$[trade_rXr(r,r2) and par_fuel_regional_rXr(r,r2,f)], FUEL_REGIONAL_rXr(r,r2,f,y)}
* Imported
+ sum{(rimp)$[trade_rXrimp(r,rimp) and par_fuel_import_rXrimp(r,rimp,f)], FUEL_IMPORT_rXrimp(r,rimp,f,y)}
;
*$offtext

*_ FUEL RESOURCE AVAILABILITY
equation  EQ_fuel_production_local(n,f,yall)  "Fuel resource production at local";
EQ_fuel_production_local(n,f,y)..
fuel_production_local(n,f,y)  =g=  FUEL_LOCAL(n,f,y);

equation  EQ_fuel_production_regional(r,f,yall)  "Fuel resource production at regional";
EQ_fuel_production_regional(r,f,y)..
fuel_production_regional(r,f,y)  =g=  sum{(r2)$[trade_rXr(r,r2)], FUEL_REGIONAL_rXr(r2,r,f,y)}
                                         + sum{(n)$[map_nXr(n,r)], FUEL_LOCAL(n,f,y)};

*_ FUEL RESOURCE RESERVE
equation  EQ_fuel_reserve_local(n,f)  "Fuel resource reserve at local";
EQ_fuel_reserve_local(n,f)$[fos(f) or nuc(f)]..
fuel_reserve_local(n,f)  =g=  sum{(y), FUEL_LOCAL(n,f,y)};

equation  EQ_fuel_reserve_regional(r,f)  "Fuel resource reserve at regional";
EQ_fuel_reserve_regional(r,f)$[fos(f) or nuc(f)]..
fuel_reserve_regional(r,f)  =g=  sum{(r2,y)$[trade_rXr(r,r2)], FUEL_REGIONAL_rXr(r2,r,f,y)}
                                 + sum{(n,y)$[map_nXr(n,r)], FUEL_LOCAL(n,f,y)};

*_ RENEWABLE ENERGY RESOURCE MAXIMUM POTENTIAL INSTALLED CAPACITY
equation  EQ_potMW_geot(n,yall)  "Cap on potential geothermal capacity";
EQ_potMW_geot(n,y)..
potMW_geot(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_geot(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)};

equation  EQ_potMW_hydrodam(n,yall)  "Cap on potential hydro-dam capacity";
EQ_potMW_hydrodam(n,y)..
potMW_hydrodam(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_hydd(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)};

equation  EQ_potMW_hydroror(n,yall)  "Cap on potential mini-hydro run-off-river capacity";
EQ_potMW_hydroror(n,y)..
potMW_hydroror(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_hydr(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)}
                        + sum{(eg,v)$[sit_eg(n,eg) and eg_hydrr(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)};

*_ SOLAR-WIND INSTALLED CAPACITY LIMITS ON LAND AVAILABILITY
equation  EQ_land_winn(n,yall)  "Cap on potential on-shore wind solar power capacity";
EQ_land_winn(n,y)..
land_usw(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_winn(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)*eg_landuse(eg)};

equation  EQ_land_usw(n,yall)  "Cap on potential utility scale solar power capacity";
EQ_land_usw(n,y)..
land_usw(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_usw(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)*eg_landuse(eg)};

equation  EQ_land_dgen(n,yall)  "Cap on potential distributed scale solar power capacity";
EQ_land_dgen(n,y)..
land_dgen(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_dgen(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)*eg_landuse(eg)};

*_ MAXIMUM POTENTIAL INSTALLED CAPACITY GENERATION CAPACITIES
equation  EQ_maxbuild_mw_greg(n,greg,yall)  "Spatial-limit on built electricity generation capacity by technology group";
EQ_maxbuild_mw_greg(n,greg,y)$[maxbuild_mw_greg(n,greg)]..
maxbuild_mw_greg(n,greg)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_greg(eg,greg) and (v.val <= y.val)], egCAP(n,eg,v,y)};

*_ RENEWABLE ENERGY RESOURCE AVAILABILITY
*__ Solar power
equation  EQ_egINMIX_csp(n,eg,v,yall)  "Concentrating solar power (CSP) resource availability";
EQ_egINMIX_csp(n,eg,v,y)$[sit_eg(n,eg) and eg_csp(eg) and v.val <= y.val]..
egINMIX(n,eg,v,y)  =l=  egCAP(n,eg,v,y)*eg_surfacearea(eg)*(csp_dni(n)*fulldays);

equation  EQ_egINMIX_upv(n,eg,v,yall)  "Utility-scale photovoltaic (UPV) resource availability";
EQ_egINMIX_upv(n,eg,v,y)$[sit_eg(n,eg) and eg_upv(eg) and v.val <= y.val]..
egINMIX(n,eg,v,y)  =l=  egCAP(n,eg,v,y)*eg_surfacearea(eg)*(upv_ghi(n)*fulldays);

equation  EQ_egINMIX_dpv(n,eg,v,yall)  "Distributed photovoltaic (DPV) resource availability";
EQ_egINMIX_dpv(n,eg,v,y)$[sit_eg(n,eg) and eg_dpv(eg) and v.val <= y.val]..
egINMIX(n,eg,v,y)  =l=  egCAP(n,eg,v,y)*eg_surfacearea(eg)*(dpv_ghi(n)*fulldays);

* Wind power
equation  eq_egOUT_winn(n,eg,v,yall)  "On-shore utility scale wind resource availability";
eq_egOUT_winn(n,eg,v,y)$[sit_eg(n,eg) and eg_winn(eg) and v.val <= y.val]..
egOUT_ely(n,eg,v,y) *1000  =l=  (egCAP(n,eg,v,y)*fullhours) *usw_windcf(n,eg);

* Hydro power, dam
equation  eq_egOUT_hydd(n,eg,v,yall)  "Hydropower dam resource availability";
eq_egOUT_hydd(n,eg,v,y)$[sit_eg(n,eg) and eg_hydd(eg) and v.val <= y.val]..
egOUT_ely(n,eg,v,y) *1000  =l=  (egCAP(n,eg,v,y)*fullhours) *cfdam(n);

equation  eq_egOUT_hydr(n,eg,v,yall)  "Minihydro resource availability";
eq_egOUT_hydr(n,eg,v,y)$[sit_eg(n,eg) and eg_hydr(eg) and v.val <= y.val]..
egOUT_ely(n,eg,v,y) *1000  =l=  (egCAP(n,eg,v,y)*fullhours) *cfror(n);

equation  eq_egOUT_hydrr(n,eg,v,yall)  "Microhydro resource availability";
eq_egOUT_hydrr(n,eg,v,y)$[sit_eg(n,eg) and eg_hydrr(eg) and v.val <= y.val]..
egOUT_ely(n,eg,v,y) *1000  =l=  (egCAP(n,eg,v,y)*fullhours) *cfror(n);



*===============================================================================
*# ELECTRICITY GENERATION
*===============================================================================
*_ CAPACITY FACTOR
equation  EQ_eg_cfmax(n,eg,v,yall)  "Maximum capacity factor of power generation";
EQ_eg_cfmax(n,eg,v,y)$[sit_eg(n,eg) and eg_cfmax(eg) and v.val <= y.val]..
eg_cfmax(eg)* (egCAP(n,eg,v,y)*fullhours)  =g=  egOUT_ely(n,eg,v,y)*1000;
* Maximum CF considers plant outages and 'peaker' power plants

equation  EQ_eg_cfmin(n,eg,v,yall)  "Electricity generation of power generation";
EQ_eg_cfmin(n,eg,v,y)$[sit_eg(n,eg) and eg_cfmin(eg) and v.val <= y.val]..
eg_cfmin(eg)* (egCAP(n,eg,v,y)*fullhours)  =l=  egOUT_ely(n,eg,v,y)*1000;
* Minimum CF ensures economic dispatch of 'baseload' power plants

*_ INPUT-OUTPUT
equation  EQ_egINPUTOUTPUT(n,eg,v,yall)  "Input-output and process efficiency of power generation";
EQ_egINPUTOUTPUT(n,eg,v,y)$[sit_eg(n,eg) and v.val <= y.val]..
egINMIX(n,eg,v,y)*eg_eef(eg)  =e=  egOUT_ely(n,eg,v,y);

*_ INPUT FUEL
equation  EQ_egINMIX_firing(n,eg,v,yall)  "Fuel mixture in fuel-firing power plant";
EQ_egINMIX_firing(n,eg,v,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..
egINMIX(n,eg,v,y)  =e=  sum{(f)$[eg_fuelmix(eg,f,y)], egFUEL(n,eg,v,f,y)}*gw_pj;

equation  EQ_eg_fuelmix(n,eg,v,f,yall)  "Fuelmix limits";
EQ_eg_fuelmix(n,eg,v,f,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..
eg_fuelmix(eg,f,y)*egINMIX(n,eg,v,y)  =g=  egFUEL(n,eg,v,f,y)*gw_pj;

*_ CO2 EMISSIONS
equation  EQ_egCO2ems(n,eg,v,yall)  "CO2 emissions from power generation";
EQ_egCO2ems(n,eg,v,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..
egCO2ems(n,eg,v,y)  =e=  sum{(f)$[eg_fuelmix(eg,f,y)], egFUEL(n,eg,v,f,y)*emsf_CO2(f)}$[eg_firing(eg)];

*_ CO2 EMISSIONS FROM BIOENERGY
equation  EQ_egCO2bio(n,eg,v,yall)  "CO2 neutral from power generation";
EQ_egCO2bio(n,eg,v,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..
egCO2bio(n,eg,v,y)  =e=  sum{(f)$[bio(f) and eg_fuelmix(eg,f,y)], egFUEL(n,eg,v,f,y)*emsf_CO2(f)}$[eg_firing(eg)];

*_ CO2 CAPTURE
equation  EQ_egCCX(n,eg,v,yall)  "CO2 captured from power generation";
EQ_egCCX(n,eg,v,y)$[sit_eg(n,eg) and eg_rateCCX(eg) and v.val <= y.val]..
egCCX(n,eg,v,y)  =e=  egCO2ems(n,eg,v,y)*eg_rateCCX(eg);



*===============================================================================
*# CO2 TRANSPORT AND STORAGE
*===============================================================================
*_ CO2 BALANCE AND SOURCE-SINK MATCHING
equation  EQ_CO2BALANCE(n,yall)  "CO2 source-sink matching";
EQ_CO2BALANCE(n,y)..
* Injected/stored at
CINJECT(n,y)$[csink(n)]  =e=
* Captured at
sum{(eg,v)$[sit_eg(n,eg) and eg_rateCCX(eg) and v.val <= y.val], egCCX(n,eg,v,y)}
* Transported in and out
+ sum{(n2,trc)$[sit_trc(n2,n,trc)], trcFLOW_CO2(n2,n,trc,y)}
- sum{(n2,trc)$[sit_trc(n,n2,trc)], trcFLOW_CO2(n,n2,trc,y)};

*_ CO2 TRANSPORT FLOW CAPACITY
equation  EQ_trcCAPBOTH(n,n2,trc,yall)  "Capacity balance of installed electricity transmission line both ways";
EQ_trcCAPBOTH(n,n2,trc,y)$[sit_trc(n,n2,trc) or sit_trc(n2,n,trc)]..
trcCAPBOTH(n,n2,trc,y)  =e=  trcCAP(n,n2,trc,y) + trcCAP(n2,n,trc,y) ;

equation  EQ_trc_CAPFLOW(n,n2,trc,yall)  "CO2 transport capacity limits";
EQ_trc_CAPFLOW(n,n2,trc,y)$[sit_trc(n,n2,trc) or sit_trc(n2,n,trc)]..
(trcCAPBOTH(n,n2,trc,y)) *1000  =g=  trcFLOW_CO2(n,n2,trc,y);

*_ CO2 INJECTION & STORAGE
equation  EQ_maxCINJECT(n,yall)  "CO2 injection rate limits";
EQ_maxCINJECT(n,y)$[csink(n)]..  CINJECT(n,y)  =l=  maxrate_CINJECT(n);
$ontext
equation  EQ_maxCO2ROOM(n)  "CO2 storage room limits";
EQ_maxCO2ROOM(n)$[csink(n)]..    sum{(y), CINJECT(n,y)*y_length(y)}  =l=  maxroom_CSTORAGE(n);
$offtext



*===============================================================================
*# CAPACITY BALANCE AND TRANSFERS
*===============================================================================
equation  EQ_egCAP(n,eg,v,yall)  "Installed capacity of electricity generation";
EQ_egCAP(n,eg,v,y)$[sit_eg(n,eg) and v.val <= y.val]..
egCAP(n,eg,v,y)  =e=  sum{y2$[y_sequence(y2,y)], egCAP(n,eg,v,y2)$[v.val <= y2.val]}
                      + egNEW(n,eg,v)$[eg_feas_yall(eg) and v.val = y.val]
                      - egRET(n,eg,v,y)$[y.val > yrbase_val]
                      + eg_stkcap(n,eg,v)$[y.val = yrbase_val];
* egNEWi represents integer capacity addition to account for large-scale infrastructure.
* egNEWc represents continous capacity addtion for modular deployment of small-scale infrastructure.

equation  EQ_egRET(n,eg,v,yall)  "Capacity retirement of electricity generation";
EQ_egRET(n,eg,v,y)$[sit_eg(n,eg) and v.val <= y.val]..
egRET(n,eg,v,y)  =e=  sum{y2$[y_sequence(y2,y)], egCAP(n,eg,v,y2)$[(v.val <= y2.val) and ((y.val - v.val) ge eg_lifetech(eg))]};
* Retired capacity are all capacities that age has already surpass its technical lifetime.

equation  EQ_egNEW(n,eg,v)  "New additional capacity of electricity generation";
EQ_egNEW(n,eg,v)$[sit_eg(n,eg) and v.val >= yrbase_val]..
egNEW(n,eg,v)  =e=  egNEWi(n,eg,v)$[eg_NEWi(eg) and eg_feas_yall(eg)] *eg_typcap(eg)
                    + egNEWc(n,eg,v)$[eg_NEWc(eg) and eg_feas_yall(eg)]
                    + eg_codcap(n,eg,v);
* New additional capacity in the future must include prescribed capacities.

equation  EQ_subCAP(n,kv,yall)  "Installed capacity of transformer substation";
EQ_subCAP(n,kv,y)$[sit_sub(n,kv)]..
subCAP(n,kv,y)  =e=  sum{y2$[y_sequence(y2,y)], subCAP(n,kv,y2)}
                     + subNEW(n,kv,y)
                     + sub_stkcap(n,kv)$[y.val = yrbase_val];
* No capacity retirement are considered for transmission infrastructure buildouts.

equation  EQ_treCAP(n,n2,kv,yall)  "Capacity balance of installed electricity transmission line";
EQ_treCAP(n,n2,kv,y)$[sit_tre(n,n2,kv)]..
treCAP(n,n2,kv,y)  =e=  sum{y2$[y_sequence(y2,y)], treCAP(n,n2,kv,y2)}
                        + treNEW(n,n2,kv,y)
                        + tre_stkcap(n,n2,kv)$[y.val = yrbase_val];
* No capacity retirement are considered for transmission infrastructure buildouts.

equation  EQ_treNEW(n,n2,kv,yall)  "New additional capacity of electricity transmission line";
EQ_treNEW(n,n2,kv,y)$[sit_tre(n,n2,kv)]..
treNEW(n,n2,kv,y)  =e=  + treNEWi(n,n2,kv,y)$[tre_NEWi(kv)] *tre_typcap(kv)
                        + treNEWc(n,n2,kv,y)$[tre_NEWc(kv)];

equation  EQ_treCAP_prescribed(n,n2,kv,yall)  "Prescribed capacity of electricity generation";
EQ_treCAP_prescribed(n,n2,kv,y)$[sit_tre(n,n2,kv) and y.val > yrbase_val and tre_codcap(n,n2,kv,y)]..
treCAP(n,n2,kv,y)  =g=  tre_codcap(n,n2,kv,y) + tre_stkcap(n,n2,kv) ;
* Installed capacity in the future must exceed planned / under construction capacities and stock capacities accounted after base year run.

equation  EQ_trcCAP(n,n2,trc,yall)  "Capacity balance of installed CO2 transport technology";
EQ_trcCAP(n,n2,trc,y)$[sit_trc(n,n2,trc) or sit_trc(n2,n,trc)]..
trcCAP(n,n2,trc,y)  =e=  sum{y2$[y_sequence(y2,y)], trcCAP(n,n2,trc,y2)}
                         + trcNEW(n,n2,trc,y)
                         + trc_stkcap(n,n2,trc)$[y.val = yrbase_val];
* No capacity retirement are considered for CO2 transport infrastructure buildouts.

equation  EQ_trcNEW(n,n2,trc,yall)  "Capacity balance of installed CO2 transport technology";
EQ_trcNEW(n,n2,trc,y)$[sit_trc(n,n2,trc) or sit_trc(n2,n,trc)]..
trcNEW(n,n2,trc,y)  =e=  + trcNEWi(n,n2,trc,y)$[trc_NEWi(trc)]*trc_typcap(trc)
                         + trcNEWc(n,n2,trc,y)$[trc_NEWc(trc)];

*_ INITIALIZE
*__ Stock capacity at initial year
treCAP.fx(n,n2,kv,yall)$[(yall.val = yrbase_val) and not tre_feas_ybase(n,n2,kv)] = tre_stkcap(n,n2,kv);
trcCAP.fx(n,n2,trc,yall)$[(yall.val = yrbase_val)] = trc_stkcap(n,n2,trc);
*__ Null capacity addition at initial year
egNEWi.fx(n,eg,yall)$[not eg_feas_ybase(eg) and (yall.val = yrbase_val)] = 0;
egNEWc.fx(n,eg,yall)$[not eg_feas_ybase(eg) and (yall.val = yrbase_val)] = 0;
*__ Null capacity addition in future years
egNEWi.fx(n,eg,yall)$[not eg_feas_yall(eg)] = 0;
egNEWc.fx(n,eg,yall)$[not eg_feas_yall(eg)] = 0;





*===============================================================================
*# CLEAR UNUSED DATASET
*===============================================================================
Option dmpSym

*===============================================================================
*# MODEL DEFINITION AND SOLVE PROCEDURE
*===============================================================================
*Model construct
Model SELARU /ALL/;

*Solver options
Option MIP = CPLEX;
Option IntVarUp = 0;
$onecho >cplex.opt
parallelmode 1
threads 4
scaind 0
epmrk 0.01
epint 0.00
relaxfixedinfeas 0
mipemphasis 0
numericalemphasis 0
memoryemphasis 1
freegamsmodel 0
iis 1
datacheck 2
eprhs 1E-6
$offecho

SELARU.IterLim = 10000E+3;
SELARU.NodLim = 1000E+3;
SELARU.ResLim = 1000E+3;
SELARU.OptCA = 0;
SELARU.OptCR = 0.03;
SELARU.Cheat = 0;
*SELARU.CutOff = 100E+12;
*SELARU.TryInt = .01;
*SELARU.PriorOpt = 0;
*SELARU.ScaleOpt = 1;
*SELARU.SolveLink = 0;
*SELARU.WorkSpace = 10000;
SELARU.OptFile = 1;





*===============================================================================
*# OBJECTIVE FUNCTION AND SOLVE STATEMENT
*===============================================================================
*Cost minimisation problem using mixed integer linear programing (MILP).
*Minimize net present value of cumulative total system costs for each modelled year steps in consecutive solves (recursive).
*Deployed capacity information are input for consecutive solves.

*$ontext
* SETUP MODEL RUN
* MODEL RUN INTERTEMPORAL START
* Initialize
y(yall) = no ;
* Start of the inter-temporal solve (perfect foresight)
* Include all periods
y(yall)$[model_horizon(yall)] = yes ;
* Solve statement
Solve SELARU using MIP minimizing Z;
* MODEL RUN INTERTEMPORAL FINISH
*$offtext

$ontext
* SETUP MODEL RUN
* MODEL RUN RECURSIVE START
* Initialize
y(yall) = no ;
* Start of the recursive loop
LOOP(yall$[model_horizon(yall)],
* Include the periods in recursion
         y(yall) = yes ;
* Include limited foresights, next-period in sequence
*         y(yall3)$[ORD(yall3) = ORD(yall)+1] = yes ;
*         y(yall3)$[ORD(yall3) = ORD(yall)+2] = yes ;
*         y(yall3)$[ORD(yall3) = ORD(yall)+3] = yes ;
* Solve statement
Solve SELARU using MIP minimizing Z;
* Write an error message and abort the solve loop if model did not solve to optimality
         IF(
         NOT(SELARU.modelstat=1 OR SELARU.modelstat=8),
         put_utility 'log' /'+++ SELARU did not solve to optimality - run is aborted, no output produced! +++ ' ;
         ABORT "SELARU did not solve to optimality!"
         );
* Fix all variables of the current iteration period 'y' to the optimal levels
         egCAP.fx(n,eg,yall2,yall)$[map_period(yall2,yall)] = egCAP.l(n,eg,yall2,yall);
         subCAP.fx(n,kv,yall) = subCAP.l(n,kv,yall);
         treCAP.fx(n,n2,kv,yall) = treCAP.l(n,n2,kv,yall);
         trcCAP.fx(n,n2,trc,yall) = trcCAP.l(n,n2,trc,yall);
* End of the recursive loop
);
* MODEL RUN RECURSIVE FINISH
$offtext



*===============================================================================
*# POST PROCESSING
*===============================================================================
$ontext
* Supply-demand balancing at NODE
parameters               p_FUEL_Xn(n,f,yall)  "(Thousands $/PJ) Ex-post price of fuel (f) at node (n) in year (yall)";
p_FUEL_Xn(n,f,yall)$[S_fuel_Xn.l(n,f,yall)] =
(
COST_FUEL_LOCAL.l(n,f,yall)
+ sum{(r)$[trade_nXr(n,r)], COST_FUEL_REGIONAL_nXr.l(n,r,f,yall)}
+ sum{(rimp)$[trade_nXrimp(n,rimp)], COST_FUEL_IMPORT_nXrimp.l(n,rimp,f,yall)}
)
/ S_fuel_Xn.l(n,f,yall)
;
$offtext

*$ontext
* Supply-demand balancing at REGION
parameters               S_fuel_Xr_postlocal(r,f,yall)  "(PJ/year) Ex-post suppy of fuel (f) at region (r) in year (yall)";
S_fuel_Xr_postlocal(r,f,yall) =
S_fuel_Xr.l(r,f,yall) + sum{(n)$[map_nXr(n,r)], FUEL_LOCAL.l(n,f,yall)}

parameters               p_FUEL_Xr(r,f,yall)  "(Thousands $/PJ) Ex-post price of fuel (f) at node (n) in year (yall)";
p_FUEL_Xr(r,f,yall)$[S_fuel_Xr_postlocal(r,f,yall)] =
(
sum{(n)$[map_nXr(n,r)], COST_FUEL_LOCAL.l(n,f,yall)}
+ sum{(r2)$[trade_rXr(r,r2)], COST_FUEL_REGIONAL_rXr.l(r,r2,f,yall)}
+ sum{(rimp)$[trade_rXrimp(r,rimp)], COST_FUEL_IMPORT_rXrimp.l(r,rimp,f,yall)}
)
/ S_fuel_Xr_postlocal(r,f,yall)
;
* Nodal fuel price are the same with regional price
parameters               p_FUEL_Xn(n,f,yall)  "(Thousands $/PJ) Ex-post price of fuel (f) at node (n) in year (yall)";
p_FUEL_Xn(n,f,yall) = sum{(r)$[map_nXr(n,r)], p_FUEL_Xr(r,f,yall)};
*$offtext

parameters               COST_egFUEL(n,eg,v,yall)  "(Thousands $/year) Annual costs of fuel for electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)";
COST_egFUEL(n,eg,v,yall)$[sit_eg(n,eg) and v.val <= yall.val]
= sum{(f), egFUEL.l(n,eg,v,f,yall)*p_FUEL_Xn(n,f,yall)};

parameters               LC_eg(n,eg,v,yall)  "(c$/kWh) Levelized cost of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
                         LC_sub(n,kv,yall)  "(c$/kWh) Levelized cost of transformer-substation voltage class (kv) that was built in year (v) at node (n) in year (yall)"
                         LC_tre(n,n2,kv,yall)  "(c$/kWh) Levelized cost of electricity transmission voltage class (kv)  that was built in year (v) from node (n) to another node (n2) in year (yall)"
                         LC_trc(n,n2,trc,yall)  "(c$/kWh) Levelized cost of CO2 transport technology type (trc) from node (n) to another node (n2) in year (yall)";
LC_eg(n,eg,v,yall)$[sit_eg(n,eg) and v.val <= yall.val and egOUT_ely.l(n,eg,v,yall)]
= (COST_egANNCAPEX.l(n,eg,v,yall)
   + COST_egFOM.l(n,eg,v,yall)
   + COST_egVOM.l(n,eg,v,yall)
   + COST_egFUEL(n,eg,v,yall)
   )/egOUT_ely.l(n,eg,v,yall);

parameters               subFLOW_ely(n,kv,yall)  "(GWh/year) Annual electricity transformation at transformer substation voltage class (kv) at node (n) in year (yall)";
subFLOW_ely(n,kv,yall) =
sum{(kv2)$[kv2.val > kv.val], subVUP_ely.l(n,kv,kv2,yall)}
+ sum{(kv2)$[kv2.val < kv.val], subVDO_ely.l(n,kv,kv2,yall)}
+ sum{(kv2)$[kv2.val > kv.val], subVUP_ely.l(n,kv2,kv,yall)}
+ sum{(kv2)$[kv2.val < kv.val], subVDO_ely.l(n,kv2,kv,yall)};

LC_sub(n,kv,yall)$[sit_sub(n,kv) and subFLOW_ely(n,kv,yall)]
= COST_sub.l(n,kv,yall)/subFLOW_ely(n,kv,yall);

LC_tre(n,n2,kv,yall)$[sit_tre(n,n2,kv) and treFLOW_ely.l(n,n2,kv,yall)]
= COST_tre.l(n,n2,kv,yall)/treFLOW_ely.l(n,n2,kv,yall);

LC_trc(n,n2,trc,yall)$[sit_trc(n,n2,trc) and trcFLOW_CO2.l(n,n2,trc,yall)]
= COST_trc.l(n,n2,trc,yall)/trcFLOW_CO2.l(n,n2,trc,yall);

parameters               CF_eg(n,eg,v,yall)  "Capacity factor of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
                         CF_sub(n,kv,yall)  "Capacity factor of transformer-substation voltage class (kv) that was built in year (v) at node (n) in year (yall)"
                         CF_tre(n,n2,kv,yall)  "Capacity factor of electricity transmission voltage class (kv)  that was built in year (v) from node (n) to another node (n2) in year (yall)"
                         CF_trc(n,n2,trc,yall)  "Capacity factor of CO2 transport technology type (trc) from node (n) to another node (n2) in year (yall)";
CF_eg(n,eg,v,yall)$[sit_eg(n,eg) and (v.val <= yall.val) and egCAP.l(n,eg,v,yall)]
= 1000*egOUT_ely.l(n,eg,v,yall)/(egCAP.l(n,eg,v,yall)*8760);

CF_sub(n,kv,yall)$[sit_sub(n,kv) and subCAP.l(n,kv,yall)]
= 1000*(sum{(kv2)$[kv2.val > kv.val], subVUP_ely.l(n,kv,kv2,yall)}
   + sum{(kv2)$[kv2.val < kv.val], subVDO_ely.l(n,kv,kv2,yall)}
   + sum{(kv2)$[kv2.val > kv.val], subVUP_ely.l(n,kv2,kv,yall)}
   + sum{(kv2)$[kv2.val < kv.val], subVDO_ely.l(n,kv2,kv,yall)}
   )/(subCAP.l(n,kv,yall)*8760);

CF_tre(n,n2,kv,yall)$[sit_tre(n,n2,kv) and treCAP.l(n,n2,kv,yall)]
= 1000*treFLOW_ely.l(n,n2,kv,yall)/(treCAP.l(n,n2,kv,yall)*8760);

CF_trc(n,n2,trc,yall)$[sit_trc(n,n2,trc) and trcCAP.l(n,n2,trc,yall)]
= trcFLOW_CO2.l(n,n2,trc,yall)/(trcCAP.l(n,n2,trc,yall)*8760);

parameters               INVEST_eg(n,eg,v,yall)  "(Thousands $) Capital investment of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
                         INVEST_sub(n,kv,yall)  "(Thousands $) Capital investment of transformer-substation voltage class (kv) that was built in year (v) at node (n) in year (yall)"
                         INVEST_tre(n,n2,kv,yall)  "(Thousands $) Capital investment of electricity transmission voltage class (kv)  that was built in year (v) from node (n) to another node (n2) in year (yall)"
                         INVEST_trc(n,n2,trc,yall)  "(Thousands $) Capital investment of CO2 transport technology type (trc) from node (n) to another node (n2) in year (yall)";
INVEST_eg(n,eg,v,yall)$[yall.val = v.val] = egNEW.l(n,eg,v)*eg_capex(n,eg,yall)$[yall.val = v.val];
INVEST_sub(n,kv,yall) = subNEW.l(n,kv,yall)*sub_capex(n,kv,yall);
INVEST_tre(n,n2,kv,yall) = treNEW.l(n,n2,kv,yall)*(
         (distance_onshore_tre(n,n2)*tre_capex_overland(n,n2,kv,yall))
         +(distance_offshore_tre(n,n2)*tre_capex_oversea(n,n2,kv,yall))
         );
INVEST_trc(n,n2,trc,yall) = trcNEW.l(n,n2,trc,yall)*(
         (distance_onshore_trc(n,n2)*trc_capex_overland(n,n2,trc,yall))
         +(distance_offshore_trc(n,n2)*trc_capex_oversea(n,n2,trc,yall))
         );



* Write results to .gdx file
execute_unload 'out-pf_%spatialscenario%_%climatescenario%.gdx';


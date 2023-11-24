$title SELARU 1.1 - Indonesia

$offSymXRef
$offSymList
option limRow = 0, limCol = 0;
option solPrint = silent;

$set spatialscenario     "highres"
$set climatescenario     "BL"

$set inputfile           "selaru1.1_input_%spatialscenario%.gdx"
$set inputclimate        "selaru1.1_input_climate_policy.gdx"



*============================================================
*INPUT DATASET PREPARATION
*============================================================
*Defining names for model input dataset in .gdx file
parameters       par_years(*,*)  "Timesteps and planning horizon"
                 par_mapregion(*,*,*)  "Region mapping of nodes (balancing areas)"
                 par_nodes(*,*)  "Nodes of supply-demand locations"
                 par_nodes_plrsv(*,*)  "Nodes planning reserve margin"
                 par_sit_eg(*,*)  "Sitting of power generation"
                 par_sit_sub(*,*)  "Sitting of transformer-substation"
                 par_sit_tre(*,*,*)  "Sitting of transmission line"
                 par_bio_blending(*,*)  "Bioenergy blending"
                 par_fuel(*,*)  "Fuels"
                 par_kv(*,*)  "Voltage classes"
                 par_eg(*,*)  "Electricity generation infrastructure"
                 par_sub(*,*)  "Transformer-substation infrastructure"
                 par_tre(*,*)  "Transmission line infrastructure"
                 par_rsc_geot(*,*)  "Geothermal resource"
                 par_rsc_hydro(*,*)  "Hydropower resource"
                 par_RSC_usw(*,*)  "Utility scale solar and wind resource"
                 par_RSC_dgen(*,*)  "Distributed generation resource"
                 par_demand(*,*)  "Demand"
                 par_stk_eg(*,*,*,*)  "Stock build capacity of electricity generation infrastructure"
                 par_stk_sub(*,*,*)  "Stock build capacity of electricity transformer-substation"
                 par_stk_tre(*,*,*,*)  "Stock build capacity of electricity transmission line"
                 par_cod_eg(*,*,*,*)  "Planned capacity of electricity generation infrastructure"
                 par_cod_tre(*,*,*,*,*)  "Planned capacity of electricity transmission line"
;
*Loading values for model input dataset from reading .gdx file
$gdxIn   %inputfile%
$loaddc  par_years
$loaddc  par_mapregion
$loaddc  par_nodes
$loaddc  par_nodes_plrsv
$loaddc  par_sit_eg
$loaddc  par_sit_sub
$loaddc  par_sit_tre
$loaddc  par_bio_blending
$loaddc  par_fuel
$loaddc  par_kv
$loaddc  par_eg
$loaddc  par_sub
$loaddc  par_tre
$loaddc  par_rsc_geot
$loaddc  par_rsc_hydro
$loaddc  par_rsc_usw
$loaddc  par_rsc_dgen
$loaddc  par_demand
$loaddc  par_stk_eg
$loaddc  par_stk_sub
$loaddc  par_stk_tre
$loaddc  par_cod_eg
$loaddc  par_cod_tre



*============================================================
*# SETS AND INDICE3S (SUFFIX)
*============================================================
* TEMPORAL
sets     yall  "All years"
         y(yall)  "Years included in a model instance"
         yfirst(yall)  "Base year of model run"
         ylast(yall)  "Last year of model run"
         model_horizon(yall)  "Years considered in model instance";
$gdxIn %inputfile%
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

* SPATIAL
sets     r  "Regions"
         n  "Nodes"
         mapregion(r,n) "Mapping of node and region";
$gdxIn %inputfile%
$loaddc  r
$loaddc  n
alias    (r,reg2);
alias    (n,n2);

mapregion(r,n) = yes$[par_mapregion(r,n,'area_sqkm')];

*_ ELECTRICITY TRANSMISSION INFRASTRUCTURE
sets     kv  "Voltage classes"
         typ_oprsv  "Types of operating reserve"
         cat_oprsv  "Categories of operating reserve"
         tre_NEWc(kv)  "Transmission line infrastructure (kv) with continuos capacity addition"
         tre_NEWi(kv)  "Transmission line infrastructure (kv) with integer capacity addition";
$gdxIn %inputfile%
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
         eg_biotank(eg)  "Biogas tank reactor coupled power generation infrastructure (eg)"
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
         eg_dgen(eg)  "Distributed power generation infrastructure (eg)"
         eg_feas_ybase(eg)  "Power generation infrastructure (eg) that are feasible to add at base year"
         eg_feas_yall(eg)  "Power generation infrastructure (eg) that are feasible to add at future years";
$gdxIn %inputfile%
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
eg_biotank(eg) = yes$[par_eg(eg,'biotank') eq 1];
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
eg_feas_ybase(eg) = yes$[par_eg(eg,'feas_ybase') eq 1];
eg_feas_yall(eg) = yes$[par_eg(eg,'feas_yall') eq 1];

*_ FUELS
sets     f  "Types of fuel"
         bio(f)  "Bio-based fuels"
         fos(f)  "Fossil fuels"
         nuc(f)  "Nuclear fuels";
$loaddc  f
bio(f) = yes$[par_fuel(f,'bio') eq 1];
fos(f) = yes$[par_fuel(f,'fos') eq 1];
nuc(f) = yes$[par_fuel(f,'uranium') eq 1];

*_ TECHNOLOGY/INFRASTRUCTURE SITTING
sets     sit_eg(n,eg)  "Sitting of electricity generation infrastructure (eg) at node (n)"
         sit_sub(n,kv)  "Sitting of electricity transformer-substation infrastructure (sub) at node (n)"
         sit_tre(n,n2,kv)  "Sitting of electricity transmission line infrastructure (tre) from node (n) to another node (n2)"
;
sit_eg(n,eg) = yes$[par_sit_eg(n,eg) eq 1];
sit_sub(n,kv) = yes$[par_sit_sub(n,kv) eq 1];
sit_tre(n,n2,kv) = yes$[par_sit_tre(n,n2,kv) eq 1];



*============================================================
*# PARAMETERS
*============================================================
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
$gdxIn %inputfile%
$loaddc  yrbase_val

*_ SPATIAL
parameters       distance_onshore_tre(n,n2)  "(km) Total distance onshore electricity transmission line from node (n) to another location (n2)"
                 distance_offshore_tre(n,n2)  "(km) Total distance offshore electricity transmission line from node (n) to another location (n2)";
distance_onshore_tre(n,n2) = par_sit_tre(n,n2,'onshore_km');
distance_offshore_tre(n,n2) = par_sit_tre(n,n2,'offshore_km');

*_ ELECTRICITY TRANSMISSION INFRASTRUCTURE
*__ Transmission line
parameters       tre_typcap(kv)  "(MW) Typical capacity (size) of transmission line voltage class (kv)"
                 tre_anncapex_overland(n,n2,kv,yall)  "(US$/MW-km) Investment annuity of transmission line voltage class (kv) overland"
                 tre_anncapex_oversea(n,n2,kv,yall)  "(US$/MW-km) Investment annuity of transmission line voltage class (kv) oversea"
                 tre_losses_overland(n,n2,kv)  "Losses rate per 10km of transmission line voltage class (tre) overland"
                 tre_losses_oversea(n,n2,kv)  "Losses rate per 10km of transmission line voltage class (tre) oversea"
                 tre_cfmax(kv)  "Maximum capacity factor of technology type (tre)"
                 tre_cfmin(kv)  "Minimum capacity factor of technology type (tre)";
tre_typcap(kv) = par_tre(kv,'typcap');
tre_anncapex_overland(n,n2,kv,yall) = par_tre(kv,'anncapex')*(1+par_sit_tre(n,n2,'mxland_capex'))*par_years(yall,kv);
tre_anncapex_oversea(n,n2,kv,yall) = par_tre(kv,'anncapex')*(1+par_sit_tre(n,n2,'mxsea_capex'))*par_years(yall,kv);
tre_losses_overland(n,n2,kv) = par_tre(kv,'losses_10km')*(1+par_sit_tre(n,n2,'mxland_losses'));
tre_losses_oversea(n,n2,kv) = par_tre(kv,'losses_10km')*(1+par_sit_tre(n,n2,'mxsea_losses'));
tre_cfmax(kv) = par_tre(kv,'cfmax');
tre_cfmin(kv) = par_tre(kv,'cfmin');
*__ Transformer substation
parameters       sub_typcap(kv) "(MW) Typical capacity (size) of technology type (sub)"
                 sub_anncapex(n,kv,yall)  "(US$/MW) Annual carrying costs (CAPEX+OPEX) of technology type (sub)"
                 sub_losses(kv)  "Losses rate electricity voltage transformation of technology type (sub)"
                 sub_cfmax(kv)  "Maximum capacity factor of technology type (sub)";
sub_typcap(kv) = par_sub(kv,'typcap');
sub_anncapex(n,kv,yall) = par_sub(kv,'anncapex')*(1+par_sit_sub(n,'mx_capex'))*par_years(yall,kv);
sub_losses(kv) = par_sub(kv,'losses');
sub_cfmax(kv) = par_sub(kv,'cfmax');
*__ National aggregated values
parameters       dst_lineloss  "Distribution line losses"
                 dst_subloss  "Distribution substation ownuse"
                 nattre_losses  "Tranmission line losses"
                 nattre_ownuse  "Transmission line ownuse"
                 natsub_ownuse  "Transmission substation ownuse";
$gdxIn %inputfile%
$loaddc  dst_lineloss
$loaddc  dst_subloss
$loaddc  nattre_losses
$loaddc  nattre_ownuse
$loaddc  natsub_ownuse

*_ ELECTRICITY GENERATION INFRASTRUCTURE
parameters       eg_typcap(eg)  "(MW) Typical capacity (size) of technology type (eg)"
                 eg_lifetech(eg)  "(years) Lifetime of technology type (eg)"
                 eg_anncapex(n,eg,yall)  "(US$/kW) Annuity of investment (CAPEX) of technology type (eg) in year (yall)"
                 eg_fom(n,eg,yall)  "(US$/kW) Fixed operation and maintenance costs of technology type (eg) in year (yall)"
                 eg_vom(n,eg,yall)  "(US$/MWh) Variable operation and maintenance costs of technology type (eg) in year (yall)"
                 eg_fuelmix(eg,f,yall)  "Maximum share of feedstock fuel commodity (f) in input feedstock mixture of technology type (eg) in year (yall)"
                 eg_cfmax(eg)  "Maximum capacity factor of technology type (eg)"
                 eg_cfmin(eg)  "Minimum capacity factor of technology type (eg)"
                 eg_eef(eg)  "Rate of energy conversion efficiency of technology type (eg)"
                 eg_ramprate(eg)  "(fraction/minute) Ramp rate of dispatchable generator technology type (eg)"
                 eg_creditplrsv(eg)  "Fraction of capacity available for planning reserve credits of technology type (eg)"
                 eg_surfacearea(eg)  "(m2/MW) Surface area per unit capacity of solar RES generation technology type (eg)"
                 eg_landuse(eg)  "(m2/MW) Land use per unit capacity of generation technology type (eg)"
;
eg_typcap(eg) = par_eg(eg,'typcap');
eg_lifetech(eg) = par_eg(eg,'life_tech');
eg_anncapex(n,eg,yall) = par_eg(eg,'anncapex')*(1+par_sit_eg(n,'mx_capex'))*par_years(yall,eg);
eg_fom(n,eg,yall) = par_eg(eg,'fom');
eg_vom(n,eg,yall) = par_eg(eg,'vom');
eg_fuelmix(eg,f,yall) = par_eg(eg,f);
*_ Bioenergy blending limits
eg_fuelmix(eg,'biod',yall)$[par_eg(eg,'biod')] = par_bio_blending(yall,'biod_mix');
eg_cfmax(eg) = par_eg(eg,'cfmax');
eg_cfmin(eg) = par_eg(eg,'cfmin');
eg_eef(eg) = par_eg(eg,'eef_ely');
eg_ramprate(eg) = par_eg(eg,'ramprate');
eg_creditplrsv(eg) = par_eg(eg,'creditplrsv');
eg_surfacearea(eg) = par_eg(eg,'surfacearea');
eg_landuse(eg) = par_eg(eg,'m2_mw');

*_ FUELS
parameters       price_FUEL(n,f,yall)  "(US$/GJ) Price of energy commodity (f)"
                 emsf_CO2(f)  "(kgCO2/GJ) CO2 emissions factor of energy commodity (f)"
                 mwh_gj  "MWh/GJ conversion"/0.28/;
price_FUEL(n,f,yall) = par_fuel(f,'price_gj')*(1+par_nodes(n,f))*par_years(yall,f);
emsf_CO2(f) = par_fuel(f,'emsf_CO2');

*_RENEWABLE ENERGY SOURCE (RES)
parameters       potMW_geot(n)  "(MW) Potential generation capacity of Geothermal resource at node (n)"
                 potMW_hydrodam(n)  "(MW) Potential generation capacity of Large Hydropower, Dam resource at node (n)"
                 potMW_hydroror(n)  "(MW) Potential generation capacity of Micro-Hydropower, Run-off-river resource at node (n)"
                 cfdam(n)  "Resource-capacity factor of hydropower dam at node (n)"
                 cfror(n)  "Resource-capacity factor of hydropower run-off-river  at node (n)"
                 land_usw(n)  "(m2) Land availability for utilitily scale solar and wind power infrastructure at node (n)"
                 land_dgen(n)  "(m2) Land availability for distributed generation infrastructure at node (n)"
                 csp_dni(n)  "(kWh/m2) Long-term average daily direct normal irradiation (DNI) of CSP at node (n)"
                 upv_ghi(n)  "(kWh/m2) Long-term average daily global horizontal irradiation (GHI) of UPV at node (n)"
                 dpv_ghi(n)  "(kWh/m2) Long-term average daily global horizontal irradiation (GHI) of DPV at node (n)"
                 usw_windcf(n,eg)  "Resource-capacity factor of wind-turbine class (eg) of WINN at node (n)";
potMW_geot(n) = par_rsc_geot(n,'max_mw');
potMW_hydrodam(n) = par_rsc_hydro(n,'mw_dam');
potMW_hydroror(n) = par_rsc_hydro(n,'mw_ror');
cfdam(n) = par_rsc_hydro(n,'cf_dam');
cfror(n) = par_rsc_hydro(n,'cf_ror');
land_usw(n) = par_rsc_usw(n,'area_sqkm_usw')*10**6;
land_dgen(n) = par_rsc_dgen(n,'area_sqkm_dgen')*10**6;
csp_dni(n) = par_rsc_usw(n,'DNI');
upv_ghi(n) = par_rsc_usw(n,'GHI');
dpv_ghi(n) = par_rsc_dgen(n,'GHI');
usw_windcf(n,'WINN-IEC1-S') = par_rsc_usw(n,'CF_IEC1');
usw_windcf(n,'WINN-IEC2-S') = par_rsc_usw(n,'CF_IEC2');
usw_windcf(n,'WINN-IEC3-XS') = par_rsc_usw(n,'CF_IEC3');

*_ MAXIMUM BUILD CAPACITY
parameters       potMW_greg(n,greg)  "(MW) Limit on build capacity of electricity generation technology group (greg) at node (n)";
potMW_greg(n,'largethermal') = par_sit_eg(n,'max_largethermal');
potMW_greg(n,'engine') = par_sit_eg(n,'max_engine');
potMW_greg(n,'biogas') = par_sit_eg(n,'max_biogas');

*_ STOCK AND PRESCRIBED INFRASTRUCTURE
parameters       eg_stkcap(n,eg,yall)  "(MW) Capacity of stock electricity generation technology type (eg) at node (n) that was built in year (v)"
                 sub_stkcap(n,kv)  "(MW) Capacity of stock electricity transformer-substation voltage class(kv) at node (n) in year (yall)"
                 tre_stkcap(n,n2,kv)  "(MW) Capacity of stock electricity transmission voltage class (kv) from node (n) to another node (n2)"
                 eg_codcap(n,eg,yall)  "(MW) Capacity of planned or under-construction electricity generation technology type (eg) at node (n) that was built in year (v)"
                 tre_codcap(n,n2,kv,yall)  "(MW) Capacity of planned electricity transmission voltage class (kv) from node (n) to another node (n2) in year (yall)"
;
eg_stkcap(n,eg,yall) = par_stk_eg(n,eg,yall,'stk_MW');
sub_stkcap(n,kv) = par_stk_sub(n,kv,'stk_MW');
tre_stkcap(n,n2,kv) = par_stk_tre(n,n2,kv,'stk_MW');
eg_codcap(n,eg,yall) = par_cod_eg(n,eg,yall,'cod_MW');
tre_codcap(n,n2,kv,yall) = par_cod_tre(n,n2,kv,yall,'cod_MW');

*_ ELECTRICITY DEMAND
parameters       D_ely(n,yall)  "(MWh/year) Annual demand of electricity at node (n) in year (yall)"
                 load_factor  "Load factor of (national) grid, average production per peak load"
                 Dpeak_ely(n,yall)  "(MW) Peak demand of electricity at node (n) in year (yall)";
D_ely(n,yall) = par_demand(n,yall);
$gdxIn %inputfile%
$loaddc  load_factor
Dpeak_ely(n,yall) = par_demand(n,yall)*(1/load_factor)*(1/fullhours);

*_ PLANNING RESERVE
parameters       tgt_plrsv_margin  "Target planning reserve margin"
                 plrsv_margin(n,yall)  "Planning reserve margin at node (n) in year (yall)";
$gdxIn %inputfile%
$loaddc  tgt_plrsv_margin
plrsv_margin(n,yall) = par_nodes_plrsv(n,yall)


*_ CLIMATE POLICY
parameters       cap_co2(*,*)  "(MtCO2/year) Cap on annual total system CO2 emissions in year-step (yall) and scenario (*)";
$gdxIn   %inputclimate%
$onEPS
$loaddc  cap_co2
$offEPS

parameters       penalty_CO2ems(yall)  "($/tCO2) Tax penalty of CO2 emission"
                 credit_CINJECT(yall)  "($/tCO2) Tax credit of CO2 injection"
                 cap_CO2ems(yall)  "(MtCO2/year) Cap on annual total system CO2 emissions in year-step (yall)"
;
penalty_CO2ems(yall) = 0;
credit_CINJECT(yall) = 0;
cap_CO2ems(yall) = cap_co2(yall,'%climatescenario%');



*============================================================
*# VARIABLES
*============================================================
*# COSTS
free variables           Z  "($) Cumulative total system costs along the modelled years"
                         COST_System(yall)  "($/year) Annual cost of the total system in year (yall)";
positive variables       COST_egANNCAPEX(n,eg,v,yall)  "($/year) Investment annuity costs of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
                         COST_egFOM(n,eg,v,yall)  "($/year) Annual fixed operation and maintenance costs of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
                         COST_egVOM(n,eg,v,yall)  "($/year) Annual variable operation and maintenance costs of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
                         COST_egFUEL(n,eg,v,yall)  "($/year) Annual input feedstock costs of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
                         COST_egCTAX(n,eg,v,yall)  "($/year) Annual CO2 emissiosn penalty costs of electricity generation technology type (eg) that was built in year (v) at node (n) in year (yall)"
                         COST_sub(n,kv,yall)  "($/year) Annual investment cost of transformer-substation voltage class (kv) that was built in year (v) at node (n) in year (yall)"
                         COST_tre(n,n2,kv,yall)  "($/year) Annual investment cost of electricity transmission voltage class (kv)  that was built in year (v) from node (n) to another node (n2) in year (yall)"
;
*# ELECTRICITY GENERATION
integer variables        egNEWi(n,eg,v)  "(integer) Number of new addition electricity generation infrastructure (eg) at node (n) that was built in year (v) to account for integer variables";
positive variables       egNEWc(n,eg,v)  "(MW) Capacity of new addition electricity generation infrastructure (eg) at node (n) that was built in year (v) to account for continuous variables"
                         egNEW(n,eg,v)  "(MW) Capacity of new addition electricity generation infrastructure (eg) at node (n) that was built in year (v) to account for all variables"
                         egCAP(n,eg,v,yall)  "(MW) Capacity of installed electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egCAP_plrsv(n,eg,v,yall)    "(MW) Reserved capacity of installed electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egRET(n,eg,v,yall)  "(MW) Retired capacity of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)";
positive variables       egFUEL(n,eg,v,f,yall)  "(GJ/year) Annual consumption of fuel (f) of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egINMIX(n,eg,v,yall)  "(MWh/year) Annual energy input mixture of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egOUT_ely(n,eg,v,yall)  "(MWh/year) Annual amount of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egCF(n,eg,v,yall)  "Capacity factor of electricity generation infrastructure (eg) that was built in year (v) at node (n) in year (yall)"
                         egCO2ems(n,eg,v,yall)  "(tCO2/year) Annual CO2 emissions of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
                         egCO2bio(n,eg,v,yall)  "(tCO2/year) Annual CO2 emissions from burning of biomass of electricity generation infrastructure (eg) at node (n) that was built in year (v) in year (yall)"
;
*# TRANSFORMER-SUBSTATION
integer variables        subNEWi(n,eg,yall)  "(integer) Number of new addition transmission transformer-substation technology type (sub/kv) at node (n) that was built in year (v)";
positive variables       subNEWc(n,kv,yall)  "(MW) Capacity of new addition transformer-substation infrastructure (sub/kv)  at node (n) in year (yall)"
                         subCAP(n,kv,yall)  "(MW) Capacity of installed transformer-substation infrastructure (sub/kv) at node (n) in year (yall)";
positive variables       subVUP_ely(n,kv,kv2,yall)  "(MWh/year) Annual electricity transformed from voltage class (kv) to higher voltage class (kv2>kv) at node (n) in year (yall)"
                         subVDO_ely(n,kv,kv2,yall)  "(MWh/year) Annual electricity transformed from voltage class (kv) to lower voltage class (kv2<kv) at node (n) in year (yall)"
                         subVUP_plrsv(n,kv,kv2,yall)  "(MW) Planning reserve capacity transformed from voltage class (kv) to higher voltage class (kv2>kv) by transformer-substation technology type (sub) at node (n) in year (yall)"
                         subVDO_plrsv(n,kv,kv2,yall)  "(MW) Planning reserve capacity transformed from voltage class (kv) to lower voltage class (kv2<kv) by transformer-substation technology type (sub) at node (n) in year (yall)"
;
*# TRANSMISSION LINE
integer variables        treNEWi(n,n2,kv,yall)  "(integer) Number of new addition transmission line type (tre/kv) from node (n) to another node (n2) in year (yall)";
positive variables       treNEWc(n,n2,kv,yall)  "(MW) Capacity of new addition transmission line type (tre/kv) from node (n) to another node (n2) in year (yall)"
                         treCAP(n,n2,kv,yall)  "(MW) Capacity of installed electricity transmission line type (tre/kv) from node (n) to another node (n2) in year (yall)"
                         treCAPBOTH(n,n2,kv,yall)   "(MW) Capacity of installed electricity transmission line type (tre/kv) in both direction (n,n2) and (n,n2) in year (yall)";
positive variables       treFLOW_ely(n,n2,kv,yall)  "(MWh/year) Annual flow of electricity transmitted by transmission line type (tre/kv) from node (n) to another node (n2) in year (yall)"
                         treFLOW_plrsv(n,n2,kv,yall)  "(MW) Planning reserve capacity transmitted by transmission line type (tre/kv) from node (n) to another node (n2) in year (yall)"
;
*SUPPLY-DEMAND
positive variables       S_ely(n,kv,yall)  "(MWh/year) Annual electricity supply at node (n) of voltage class (kv) in year (yall)"
;



*===============================================================================
*# COST EQUATIONS
*===============================================================================
*_ NET PRESENT VALUE OF TOTAL SYSTEM COSTS
equation  eq_Z  "Cumulative total system costs along the modelled years";
eq_Z..   Z  =e=  sum{(y),COST_System(y)};
* Present Value (PV) to account time value of money.

*_ ANNUAL TOTAL SYSTEM COSTS
equation  EQ_COST_System(yall)  "Annual total system costs";
EQ_COST_System(y)..      COST_System(y)  =e=
sum{(n,eg,v)$[sit_eg(n,eg) and (v.val <= y.val)], COST_egANNCAPEX(n,eg,v,y)}
+ sum{(n,eg,v)$[sit_eg(n,eg) and (v.val <= y.val)], COST_egFOM(n,eg,v,y)}
+ sum{(n,eg,v)$[sit_eg(n,eg) and (v.val <= y.val)] ,COST_egVOM(n,eg,v,y)}
+ sum{(n,eg,v)$[sit_eg(n,eg) and eg_firing(eg) and (v.val <= y.val)], COST_egFUEL(n,eg,v,y)}
+ sum{(n,eg,v)$[sit_eg(n,eg) and eg_firing(eg) and (v.val <= y.val)],COST_egCTAX(n,eg,v,y)}
+ sum{(n,kv)$[sit_sub(n,kv)],COST_sub(n,kv,y)}
+ sum{(n,n2,kv)$[sit_tre(n,n2,kv)], COST_tre(n,n2,kv,y)}
;

*_ ANNUAL COSTS OF ELECTRICITY GENERATION
equation  EQ_COST_egANNCAPEX(n,eg,v,yall)  "Annual cost of electricity generation investment annuity";
EQ_COST_egANNCAPEX(n,eg,v,y)$[sit_eg(n,eg) and v.val <= y.val]..     COST_egANNCAPEX(n,eg,v,y)  =e=  egCAP(n,eg,v,y)*eg_anncapex(n,eg,v)*10**3;
equation  EQ_COST_egFOM(n,eg,v,yall)  "Annual cost of electricity generation fixed operation and maintenance";
EQ_COST_egFOM(n,eg,v,y)$[sit_eg(n,eg) and v.val <= y.val]..      COST_egFOM(n,eg,v,y)  =e=  egCAP(n,eg,v,y)*eg_fom(n,eg,y)*10**3;
equation  EQ_COST_egVOM(n,eg,v,yall)  "Annual cost of electricity generation variable operation and maintenance";
EQ_COST_egVOM(n,eg,v,y)$[sit_eg(n,eg) and v.val <= y.val]..      COST_egVOM(n,eg,v,y)  =e=  egOUT_ely(n,eg,v,y)*eg_vom(n,eg,y);
equation  EQ_COST_egFUEL(n,eg,v,yall)  "Annual cost of electricity generation input feedstock fuels";
EQ_COST_egFUEL(n,eg,v,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..   COST_egFUEL(n,eg,v,y)  =e=  sum{(f)$[eg_fuelmix(eg,f,y)], egFUEL(n,eg,v,f,y)*price_FUEL(n,f,y)};
equation  EQ_COST_egCTAX(n,eg,v,yall)  "Annual cost of electricity generation CO2 tax penalty";
EQ_COST_egCTAX(n,eg,v,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..   COST_egCTAX(n,eg,v,y)  =e=  (egCO2ems(n,eg,v,y)-egCO2bio(n,eg,v,y))*penalty_CO2ems(y);

*_ ANNUAL COSTS OF TRANSMISSION INFRASTRUCUTRE
equation  EQ_COST_sub(n,kv,yall)  "Annual cost of transformer-substation infrastructure";
EQ_COST_sub(n,kv,y)$[sit_sub(n,kv)]..    COST_sub(n,kv,y)  =e=  subCAP(n,kv,y)*sub_anncapex(n,kv,y);
equation  EQ_COST_tre(n,n2,kv,yall)  "Annual cost of transmission line infrastructure";
EQ_COST_tre(n,n2,kv,y)$[sit_tre(n,n2,kv)]..      COST_tre(n,n2,kv,y)  =e=  treCAP(n,n2,kv,y)*((distance_onshore_tre(n,n2)*tre_anncapex_overland(n,n2,kv,y))+(distance_offshore_tre(n,n2)*tre_anncapex_oversea(n,n2,kv,y)));



*===============================================================================
*# SUPPLY-DEMAND MATCHING CONSTRAINTS
*===============================================================================
*_ ELECTRICITY DEMAND
equation  EQ_DFULFILL_ely(n,kv,yall)  "Electricity demand fulfillment";
EQ_DFULFILL_ely(n,kv,y)..
D_ely(n,y)$[val_kv(kv) eq 30]*(1+dst_subloss)*(1+dst_lineloss)
=l=
S_ely(n,kv,y)$[val_kv(kv) eq 30];

equation  EQ_SDBALANCE_ely(n,kv,yall)  "Electricity supply and demand balance at node";
EQ_SDBALANCE_ely(n,kv,y)..
S_ely(n,kv,y)$[val_kv(kv) eq 30]
=e=
* Generated at
sum{(eg,v)$[sit_eg(n,eg) and v.val <= y.val],  egOUT_ely(n,eg,v,y)}$[val_kv(kv) eq 30]
* Transmitted in and out
+ sum{(n2)$[sit_tre(n2,n,kv)], treFLOW_ely(n2,n,kv,y)*(1-(tre_losses_overland(n2,n,kv)/10*distance_onshore_tre(n2,n)))*(1-(tre_losses_oversea(n2,n,kv)/10*distance_offshore_tre(n2,n)))}
- sum{(n2)$[sit_tre(n,n2,kv)], treFLOW_ely(n,n2,kv,y)}
* Voltage class step up
+ sum{(kv2)$[sit_sub(n,kv2) and sit_sub(n,kv) and val_kv(kv2) < val_kv(kv)], subVUP_ely(n,kv2,kv,y)*(1-sub_losses(kv))}
- sum{(kv2)$[sit_sub(n,kv) and sit_sub(n,kv2) and val_kv(kv2) > val_kv(kv)], subVUP_ely(n,kv,kv2,y)}
* Voltage class step down
+ sum{(kv2)$[sit_sub(n,kv2) and sit_sub(n,kv) and val_kv(kv2) > val_kv(kv)], subVDO_ely(n,kv2,kv,y)*(1-sub_losses(kv))}
- sum{(kv2)$[sit_sub(n,kv) and sit_sub(n,kv2) and val_kv(kv2) < val_kv(kv)], subVDO_ely(n,kv,kv2,y)};

*_ PLANNING RESERVES REQUIREMENTS
equation  EQ_SDBALANCE_plrsv(n,kv,yall)  "Planning reserve supply and demand balance at node";
EQ_SDBALANCE_plrsv(n,kv,y)..
* Reserves requirement
(1+plrsv_margin(n,y))*Dpeak_ely(n,y)$[val_kv(kv) eq 30]*(1+dst_subloss)*(1+dst_lineloss)
=e=
* Reserved at
sum{(eg,v)$[sit_eg(n,eg) and eg_creditplrsv(eg) and v.val <= y.val], egCAP_plrsv(n,eg,v,y)}$[val_kv(kv) eq 30]
* Transmitted in and out
+ sum{(n2)$[sit_tre(n2,n,kv)], treFLOW_plrsv(n2,n,kv,y)*(1-(tre_losses_overland(n2,n,kv)/10*distance_onshore_tre(n2,n)))*(1-(tre_losses_oversea(n2,n,kv)/10*distance_offshore_tre(n2,n)))}
- sum{(n2)$[sit_tre(n,n2,kv)], treFLOW_plrsv(n,n2,kv,y)}
* Voltage class step-up
+ sum{(kv2)$[sit_sub(n,kv2) and sit_sub(n,kv) and val_kv(kv2) < val_kv(kv)], subVUP_plrsv(n,kv2,kv,y)*(1-sub_losses(kv))}
- sum{(kv2)$[sit_sub(n,kv) and sit_sub(n,kv2) and val_kv(kv2) > val_kv(kv)], subVUP_plrsv(n,kv,kv2,y)}
* Voltage class step-down
+ sum{(kv2)$[sit_sub(n,kv2) and sit_sub(n,kv) and val_kv(kv2) > val_kv(kv)], subVDO_plrsv(n,kv2,kv,y)*(1-sub_losses(kv))}
- sum{(kv2)$[sit_sub(n,kv) and sit_sub(n,kv2) and val_kv(kv2) < val_kv(kv)], subVDO_plrsv(n,kv,kv2,y)};

equation  EQ_egCAP_plrsv(n,eg,v,yall)  "Planning reserve credit";
EQ_egCAP_plrsv(n,eg,v,y)$[sit_eg(n,eg)]..         egCAP_plrsv(n,eg,v,y)  =l=  egCAP(n,eg,v,y)*eg_creditplrsv(eg);



*===============================================================================
*# GRID INFRASTRUCTURE FLOW CAPACITY
*===============================================================================
*_ TRANSMISSION LINE, CAPACITY
equation  EQ_treCAPBOTH(n,n2,kv,yall)  "Intalled transfer capacity of transmission line for both directions";
EQ_treCAPBOTH(n,n2,kv,y)$[sit_tre(n,n2,kv) or sit_tre(n2,n,kv)]..        treCAPBOTH(n,n2,kv,y)  =e=  treCAP(n,n2,kv,y) + treCAP(n2,n,kv,y);

*_ TRANSMISSION LINE, FLOWS CAP
equation  EQ_trecfmax_ely(n,n2,kv,yall)  "Transmission line maximum capacity factor for electricity and operating reserves flows";
EQ_trecfmax_ely(n,n2,kv,y)$[sit_tre(n,n2,kv) or sit_tre(n2,n,kv)]..      fullhours*treCAPBOTH(n,n2,kv,y)*tre_cfmax(kv)  =g=  treFLOW_ely(n,n2,kv,y);
equation  EQ_trecfmax_plrsv(n,n2,kv,yall)  "Transmission line maximum capacity factor for planning reserve flows";
EQ_trecfmax_plrsv(n,n2,kv,y)$[sit_tre(n,n2,kv) or sit_tre(n2,n,kv)]..    treCAPBOTH(n,n2,kv,y)*tre_cfmax(kv)  =g=  treFLOW_plrsv(n,n2,kv,y);

*_ TRANSFORMER SUBSTATION, FLOWS CAP
equation  EQ_subcfmax_ely_vup(n,kv,yall)  "Transformation maximum capacity factor for electricity voltage transformation up";
EQ_subcfmax_ely_vup(n,kv,y)$[sit_sub(n,kv)]..    fullhours*subCAP(n,kv,y)*sub_cfmax(kv)  =g=  sum{(kv2)$[(val_kv(kv) > val_kv(kv2))], subVUP_ely(n,kv2,kv,y)};
equation  EQ_subcfmax_ely_vdo(n,kv,yall)  "Transformation maximum capacity factor for electricity voltage transformation down";
EQ_subcfmax_ely_vdo(n,kv,y)$[sit_sub(n,kv)]..    fullhours*subCAP(n,kv,y)*sub_cfmax(kv)  =g=  sum{(kv2)$[(val_kv(kv) > val_kv(kv2))], subVDO_ely(n,kv,kv2,y)};
equation  EQ_subcfmax_plrsv_vup(n,kv,yall)  "Transformation maximum capacity factor for planning reserve voltage transformation up";
EQ_subcfmax_plrsv_vup(n,kv,y)$[sit_sub(n,kv)]..  subCAP(n,kv,y)*sub_cfmax(kv)  =g=  sum{(kv2)$[val_kv(kv) > val_kv(kv2)], subVUP_plrsv(n,kv2,kv,y)};
equation  EQ_subcfmax_plrsv_vdo(n,kv,yall)  "Transformation maximum capacity factor for planning reserve voltage transformation down";
EQ_subcfmax_plrsv_vdo(n,kv,y)$[sit_sub(n,kv)]..  subCAP(n,kv,y)*sub_cfmax(kv)  =g=  sum{(kv2)$[val_kv(kv) > val_kv(kv2)], subVDO_plrsv(n,kv,kv2,y)};
equation  EQ_subcfmax_mv(n,kv,yall)  "Capacity requirement of MV transformer-substation for short-distance transmission";
EQ_subcfmax_mv(n,kv,y)$[sit_sub(n,kv) and val_kv(kv) = 30]..      subCAP(n,kv,y)*sub_cfmax(kv)  =g=  sum{(n2)$[sit_tre(n,n2,kv)], treCAP(n,n2,kv,y)} + sum{(n2)$[sit_tre(n2,n,kv)], treCAP(n2,n,kv,y)};
* MV substation capacity covers all installed inbound- and outbound-transmission capacities



*===============================================================================
*# RESOURCE AND ELECTRICITY GENERATION
*===============================================================================
*_ RENEWABLE ENERGY SOURCE (RES) MAXIMUM POTENTIAL INSTALLED CAPACITY
equation  EQ_potMW_geot(n,yall)  "Cap on potential geothermal capacity";
EQ_potMW_geot(n,y)..     potMW_geot(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_geot(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)};
equation  EQ_potMW_hydrodam(n,yall)  "Cap on potential hydro-dam capacity";
EQ_potMW_hydrodam(n,y).. potMW_hydrodam(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_hydd(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)};
equation  EQ_potMW_hydroror(n,yall)  "Cap on potential mini-hydro run-off-river capacity";
EQ_potMW_hydroror(n,y).. potMW_hydroror(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_hydr(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)}
                                             +  sum{(eg,v)$[sit_eg(n,eg) and eg_hydrr(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)};

*_ SOLAR-WIND INSTALLED CAPACITY LIMITS ON LAND AVAILABILITY
equation  EQ_land_winn(n,yall)  "Cap on potential on-shore wind solar power capacity";
EQ_land_winn(n,y)..      land_usw(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_winn(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)*eg_landuse(eg)};
equation  EQ_land_usw(n,yall)  "Cap on potential utility scale solar power capacity";
EQ_land_usw(n,y)..       land_usw(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_usw(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)*eg_landuse(eg)};
equation  EQ_land_dgen(n,yall)  "Cap on potential distributed scale solar power capacity";
EQ_land_dgen(n,y)..      land_dgen(n)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_dgen(eg) and (v.val <= y.val)], egCAP(n,eg,v,y)*eg_landuse(eg)};

*_ MAXIMUM POTENTIAL INSTALLED CAPACITY FOR GROUP/CLASS OF GENERATION TECHNOLOGIES (greg)
equation  EQ_potMW_greg(n,greg,yall)  "Spatial-limit on built electricity generation capacity by technology group";
EQ_potMW_greg(n,greg,y)$[potMW_greg(n,greg)]..   potMW_greg(n,greg)  =g=  sum{(eg,v)$[sit_eg(n,eg) and eg_greg(eg,greg) and (v.val <= y.val)], egCAP(n,eg,v,y)};

*_ INPUT FUEL
* Input mixture (egINMIX) in MW; Input feedstock (egFUEL) in GJ; 0.28 MW/GJ
equation  EQ_egINMIX_firing(n,eg,v,yall)  "Input mixture in fuel firing power plant";
EQ_egINMIX_firing(n,eg,v,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..        egINMIX(n,eg,v,y)  =e=  sum{(f)$[eg_fuelmix(eg,f,y)], egFUEL(n,eg,v,f,y)}*mwh_gj;
equation  EQ_eg_fuelmix(n,eg,v,f,yall)  "Fuelmix";
EQ_eg_fuelmix(n,eg,v,f,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..  eg_fuelmix(eg,f,y)*egINMIX(n,eg,v,y)  =g=  egFUEL(n,eg,v,f,y)*mwh_gj;

*_ INPUT RES
*__ Solar power
equation  EQ_egINMIX_csp(n,eg,v,yall)  "Concentrating solar power (CSP) resource availability";
EQ_egINMIX_csp(n,eg,v,y)$[sit_eg(n,eg) and eg_csp(eg) and v.val <= y.val]..      egINMIX(n,eg,v,y)  =l=  egCAP(n,eg,v,y)*eg_surfacearea(eg)*(csp_dni(n)/10**3)*fulldays;
equation  EQ_egINMIX_upv(n,eg,v,yall)  "Utility-scale photovoltaic (UPV) resource availability";
EQ_egINMIX_upv(n,eg,v,y)$[sit_eg(n,eg) and eg_upv(eg) and v.val <= y.val]..      egINMIX(n,eg,v,y)  =l=  egCAP(n,eg,v,y)*eg_surfacearea(eg)*(upv_ghi(n)/10**3)*fulldays;
equation  EQ_egINMIX_dpv(n,eg,v,yall)  "Distributed photovoltaic (DPV) resource availability";
EQ_egINMIX_dpv(n,eg,v,y)$[sit_eg(n,eg) and eg_dpv(eg) and v.val <= y.val]..      egINMIX(n,eg,v,y)  =l=  egCAP(n,eg,v,y)*eg_surfacearea(eg)*(dpv_ghi(n)/10**3)*fulldays;

* Wind power
equation  eq_egOUT_winn(n,eg,v,yall)  "On-shore utility scale wind resource availability";
eq_egOUT_winn(n,eg,v,y)$[sit_eg(n,eg) and eg_winn(eg) and v.val <= y.val]..      egOUT_ely(n,eg,v,y)  =l=  fullhours*egCAP(n,eg,v,y)*usw_windcf(n,eg);

* Hydro power, dam
equation  eq_egOUT_hydd(n,eg,v,yall)  "Hydropower dam resource availability";
eq_egOUT_hydd(n,eg,v,y)$[sit_eg(n,eg) and eg_hydd(eg) and v.val <= y.val]..      egOUT_ely(n,eg,v,y)  =l=  fullhours*egCAP(n,eg,v,y)*cfdam(n);
equation  eq_egOUT_hydr(n,eg,v,yall)  "Minihydro resource availability";
eq_egOUT_hydr(n,eg,v,y)$[sit_eg(n,eg) and eg_hydr(eg) and v.val <= y.val]..      egOUT_ely(n,eg,v,y)  =l=  fullhours*egCAP(n,eg,v,y)*cfror(n);
equation  eq_egOUT_hydrr(n,eg,v,yall)  "Microhydro resource availability";
eq_egOUT_hydrr(n,eg,v,y)$[sit_eg(n,eg) and eg_hydrr(eg) and v.val <= y.val]..      egOUT_ely(n,eg,v,y)  =l=  fullhours*egCAP(n,eg,v,y)*cfror(n);

*_ CAPACITY FACTOR
equation  EQ_eg_cfmax(n,eg,v,yall)  "Maximum capacity factor of power generation";
EQ_eg_cfmax(n,eg,v,y)$[sit_eg(n,eg) and eg_cfmax(eg) and v.val <= y.val]..       eg_cfmax(eg)*fullhours*egCAP(n,eg,v,y)  =g=  egOUT_ely(n,eg,v,y);
* Maximum CF considers plant outages and 'peaker' power plants
equation  EQ_eg_cfmin(n,eg,v,yall)  "Electricity generation of power generation";
EQ_eg_cfmin(n,eg,v,y)$[sit_eg(n,eg) and eg_cfmin(eg) and v.val <= y.val]..       eg_cfmin(eg)*fullhours*egCAP(n,eg,v,y)  =l=  egOUT_ely(n,eg,v,y);
* Minimum CF ensures economic dispatch of 'baseload' power plants

*_ INPUT-OUTPUT
equation  EQ_egINPUTOUTPUT(n,eg,v,yall)  "Input-output and process efficiency of power generation";
EQ_egINPUTOUTPUT(n,eg,v,y)$[sit_eg(n,eg) and v.val <= y.val]..   egINMIX(n,eg,v,y)*eg_eef(eg)  =e=  egOUT_ely(n,eg,v,y);

*_ CO2 EMISSIONS, CO2 NEUTRAL
equation  EQ_egCO2ems(n,eg,v,yall)  "CO2 emissions from power generation";
EQ_egCO2ems(n,eg,v,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..      egCO2ems(n,eg,v,y)*10**3  =e=  sum{(f)$[eg_fuelmix(eg,f,y)], egFUEL(n,eg,v,f,y)*emsf_CO2(f)}$[eg_firing(eg)];
equation  EQ_egCO2bio(n,eg,v,yall)  "CO2 neutral from power generation";
EQ_egCO2bio(n,eg,v,y)$[sit_eg(n,eg) and eg_firing(eg) and v.val <= y.val]..      egCO2bio(n,eg,v,y)*10**3  =e=  sum{(f)$[bio(f) and eg_fuelmix(eg,f,y)], egFUEL(n,eg,v,f,y)*emsf_CO2(f)}$[eg_firing(eg)];



*===============================================================================
*# CAPACITY BALANCE AND TRANSFERS, AND LUMPY INVESTMENT
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
* New additional capacity in the future must exceed planned / under construction capacities accounted after base year run.

equation  EQ_subCAP(n,kv,yall)  "Installed capacity of transformer substation";
EQ_subCAP(n,kv,y)$[sit_sub(n,kv)]..
subCAP(n,kv,y)  =e=  sum{y2$[y_sequence(y2,y)], subCAP(n,kv,y2)}
                     + subNEWc(n,kv,y)
                     + sub_stkcap(n,kv)$[y.val = yrbase_val];
* No capacity retirement are considered for transmission infrastructure buildouts.

equation  EQ_treCAP(n,n2,kv,yall)  "Capacity balance of installed electricity transmission line";
EQ_treCAP(n,n2,kv,y)$[sit_tre(n,n2,kv)]..
treCAP(n,n2,kv,y)  =e=  sum{y2$[y_sequence(y2,y)], treCAP(n,n2,kv,y2)}
                        + treNEWi(n,n2,kv,y)$[tre_NEWi(kv)] *tre_typcap(kv)
                        + treNEWc(n,n2,kv,y)$[tre_NEWc(kv)]
                        + tre_stkcap(n,n2,kv)$[y.val = yrbase_val];
* No capacity retirement are considered for transmission infrastructure buildouts.

equation  EQ_treCAP_prescribed(n,n2,kv,yall)  "Prescribed capacity of electricity generation";
EQ_treCAP_prescribed(n,n2,kv,y)$[sit_tre(n,n2,kv) and y.val > yrbase_val and tre_codcap(n,n2,kv,y)]..
treCAP(n,n2,kv,y)  =g=  tre_codcap(n,n2,kv,y) + tre_stkcap(n,n2,kv) ;
* Installed capacity in the future must exceed planned / under construction capacities and stock capacities accounted after base year run.

*_ INITIALIZE
*__ Stock capacity at initial year
treCAP.fx(n,n2,kv,yall)$[(yall.val = yrbase_val)] = tre_stkcap(n,n2,kv);
*trcCAP.fx(n,n2,trc,yall)$[(yall.val = yrbase_val)] = trc_stkcap(n,n2,trc);
*__ Null capacity addition at initial year
egNEWi.fx(n,eg,yall)$[not eg_feas_ybase(eg) and (yall.val = yrbase_val)] = 0;
egNEWc.fx(n,eg,yall)$[not eg_feas_ybase(eg) and (yall.val = yrbase_val)] = 0;
*__ Null capacity addition in future years
egNEWi.fx(n,eg,yall)$[not eg_feas_yall(eg)] = 0;
egNEWc.fx(n,eg,yall)$[not eg_feas_yall(eg)] = 0;



*============================================================
*# CLIMATE POLICY
*============================================================
*_ CAP ON ANNUAL CO2 EMISSIONS
equation  EQ_cap_CO2ems(yall)  "Cap on annual CO2 emissions";
EQ_cap_CO2ems(y)$[cap_CO2ems(y)]..  cap_CO2ems(y)*10**6  =g=  sum{(n,eg,v)$[sit_eg(n,eg) and eg_firing(eg) and (v.val<=y.val)], egCO2ems(n,eg,v,y)}
                                                              - sum{(n,eg,v)$[sit_eg(n,eg) and eg_firing(eg) and (v.val<=y.val)], egCO2bio(n,eg,v,y)}
;




*============================================================
*CLEAR UNUSED DATASET
*============================================================
Option dmpSym



*============================================================
*MODEL DEFINITION AND SOLVE PROCEDURE
*============================================================
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



*============================================================
*OBJECTIVE FUNCTION AND SOLVE STATEMENT
*============================================================
*Cost minimisation problem using mixed integer linear programing (MILP).
*Minimize net present value of cumulative total system costs for each modelled year steps in consecutive solves (recursive).
*Deployed capacity information are input for consecutive solves.

* SETUP MODEL RUN
* Change in model input parameter
$set correction 100
tre_anncapex_overland(n,n2,kv,yall) = par_tre(kv,'anncapex')*(1+par_sit_tre(n,n2,'mxland_capex'))*par_years(yall,kv)*(%correction%/100);
tre_anncapex_oversea(n,n2,kv,yall) = par_tre(kv,'anncapex')*(1+par_sit_tre(n,n2,'mxsea_capex'))*par_years(yall,kv)*(%correction%/100);

* Activate intertemporal solve by using asteriks in "$ontext" and "$offtext" before "MODEL RUN INTERTEMPORAL START" and after "MODEL RUN INTERTEMPORAL FINISH"
*$ontext
* MODEL RUN INTERTEMPORAL START
* Initialize
y(yall) = no ;
* Start of the inter-temporal solve (perfect foresight)
* Include all periods
y(yall)$[model_horizon(yall)] = yes ;
* Solve statement
Solve SELARU using MIP minimizing Z;
* Write results to .gdx file
execute_unload 'output_int-pf_%spatialscenario%_%climatescenario%_tr%correction%.gdx' ;
* MODEL RUN INTERTEMPORAL FINISH
*$offtext

* Activate recursive solve by using asteriks in "$ontext" and "$offtext" before "MODEL RUN RECURSIVE START" and after "MODEL RUN RECURSIVE FINISH"
$ontext
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
*         trcCAP.fx(n,n2,trc,yall) = trcCAP.l(n,n2,trc,yall);
* End of the recursive loop
);
* Write results to .gdx file
execute_unload 'output_rec-w0_%spatialscenario%_%climatescenario%_tr%correction%.gdx' ;
* MODEL RUN RECURSIVE FINISH
$offtext

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  set address [ipgui::add_param $IPINST -name "address"]
  set_property tooltip {address of the target router} ${address}

}

proc update_PARAM_VALUE.address { PARAM_VALUE.address } {
	# Procedure called to update address when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.address { PARAM_VALUE.address } {
	# Procedure called to validate address
	return true
}


proc update_MODELPARAM_VALUE.address { MODELPARAM_VALUE.address PARAM_VALUE.address } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.address}] ${MODELPARAM_VALUE.address}
}


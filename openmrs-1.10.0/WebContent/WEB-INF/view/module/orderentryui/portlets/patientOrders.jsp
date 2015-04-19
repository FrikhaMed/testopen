<%@ include file="/WEB-INF/template/include.jsp" %>

<script type="text/javascript">
	<openmrs:authentication>var userId = "${authenticatedUser.userId}";</openmrs:authentication>

	//initTabs
	$j(document).ready(function() {
		var c = getTabCookie();
		if (c == null) {
			var tabs = document.getElementById("patientTabs").getElementsByTagName("a");
			if (tabs.length && tabs[0].id)
				c = tabs[0].id;
		}
		changeTab(c);
	});
	
	function setTabCookie(tabType) {
		document.cookie = "dashboardOrdersTab-" + userId + "="+escape(tabType);
	}
	
	function getTabCookie() {
		var cookies = document.cookie.match('dashboardOrdersTab-' + userId + '=(.*?)(;|$)');
		if (cookies) {
			return unescape(cookies[1]);
		}
		return null;
	}
	
	function changeTab(tabObj) {
		if (!document.getElementById || !document.createTextNode) {return;}
		if (typeof tabObj == "string")
			tabObj = document.getElementById(tabObj);
		
		if (tabObj) {
			var tabs = tabObj.parentNode.parentNode.getElementsByTagName('a');
			for (var i=0; i<tabs.length; i++) {
				if (tabs[i].className.indexOf('current') != -1) {
					manipulateClass('remove', tabs[i], 'current');
				}
				var divId = tabs[i].id.substring(0, tabs[i].id.lastIndexOf("Tab"));
				var divObj = document.getElementById(divId);
				if (divObj) {
					if (tabs[i].id == tabObj.id)
						divObj.style.display = "";
					else
						divObj.style.display = "none";
				}
			}
			addClass(tabObj, 'current');
			
			setTabCookie(tabObj.id);
		}
		return false;
    }
</script>

<div id="patientTabs">
	<ul>
		<li><a id="drugOrdersTab" href="#" onclick="return changeTab(this);" hidefocus="hidefocus"><openmrs:message code="orderentryui.drugOrder"/></a></li>
		<li><a id="labOrdersTab" href="#" onclick="return changeTab(this);" hidefocus="hidefocus"><openmrs:message code="orderentryui.labOrder"/></a></li>
	</ul>
</div>

<div id="patientSections">
	<div id="drugOrders" style="display:none;">
		<openmrs:portlet url="drugOrders" id="drugDashboardOrders" patientId="${patient.patientId}" moduleId="orderentryui" />
	</div>
	<div id="labOrders" style="display:none;">
		<openmrs:portlet url="labOrders" id="labDashboardOrders" patientId="${patient.patientId}" moduleId="orderentryui" />
	</div>
</div>	
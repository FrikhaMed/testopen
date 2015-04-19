<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:htmlInclude file="/dwr/engine.js"/>
<openmrs:htmlInclude file="/dwr/util.js"/>
<openmrs:htmlInclude file="/dwr/interface/DWROrderEntryUIService.js"/>

<script type="text/javascript">

	var deleteRow;

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
		document.cookie = "drugOrdersTab-" + userId + "="+escape(tabType);
	}
	
	function getTabCookie() {
		var cookies = document.cookie.match('drugOrdersTab-' + userId + '=(.*?)(;|$)');
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
	
	function reviseDrugOrder(row, orderId) {
		if (!confirm("Are you sure you want to revise this order?")) {
			return;
		}
		
		window.location = "<openmrs:contextPath/>/module/orderentryui/drugOrder.form?patientId=${model.patient.patientId}&orderId=" + orderId;
	}
	
	function discontinueDrugOrder(row, orderId) {
		if (!confirm("Are you sure you want to discontinue this order?")) {
			return;
		}
		
		deleteRow = row;
		DWROrderEntryUIService.discontinueOrder(orderId, onDrugOrderDiscontinued);
	}
	
	function onDrugOrderDiscontinued(result) {
		if (result != null) {
			alert(result);
			return;
		}
		
		var table = document.getElementById("drugOrdersTable");
		table.deleteRow(deleteRow.rowIndex);
	}
	
</script>

<div id="portletDrugOrders">

	<div id="drugOrdersPortlet">
			&nbsp;<a
				href="<openmrs:contextPath />/module/orderentryui/drugOrder.form?patientId=${model.patient.patientId}"><openmrs:message
					code="orderentryui.add" /></a>
			<br />
			<br />
			<div>
				<table id="drugOrdersTable">
					<thead>
						<tr>
							<th>Care Setting</th>
							<th>Urgency</th>
							<th>Drug Order</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach items="${model.orders}" var="order">
				        	<tr>
				        		<td>${order.careSetting.name}</td>
				        		<td>${order.urgency}</td>
				        		<td>${order.drugOrder}</td>
				        		<td><a href="#" onclick="javascript:reviseDrugOrder(this.parentNode.parentNode, ${order.orderId});">Revise /</a></td>
				        		<td><a href="#" onclick="javascript:discontinueDrugOrder(this.parentNode.parentNode, ${order.orderId});">Discontinue</a></td>
				        	</tr>
				        </c:forEach>
					</tbody>
				</table>
			</div>
	</div>
	
</div>
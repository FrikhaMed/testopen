<%
    ui.decorateWith("appui", "standardEmrPage")
%>

<% allTypes.each { definitionType ->
    def definitions = allDefinitionLibraries.getDefinitionSummaries(definitionType)
%>

    <h2 id="${ definitionType.simpleName }">${ definitionType.simpleName }</h2>

    <table>
        <thead>
            <tr>
                <th>Name</th>
                <th>Description</th>
                <th>Parameters</th>
            </tr>
        </thead>
        <tbody>
            <% definitions.each { %>
                <tr>
                    <td>${ ui.message(it.name) }</td>
                    <td>${ ui.message(it.description) }</td>
                    <td>
                        <%= it.parameters.collect {
                                "${it.name}:${it.type.simpleName}" +
                                (it.collectionType ? "(${it.collectionType.simpleName})" : "")
                           }.join("<br/>") %>
                    </td>
                </tr>
            <% } %>
        </tbody>
    </table>

<% } %>
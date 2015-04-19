<ul>
    <li ng-repeat="et in encounterTypes">
        <input id="{{ uniqueId }}-{{ \$index }}" type="checkbox" ng-model="et.selected" ng-change="collectValues()"/>
        <label for="{{ uniqueId }}-{{ \$index }}">
            {{ et.display }}
        </label>
    </li>
</ul>
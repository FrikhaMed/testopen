<ul>
    <li ng-repeat="l in locations">
        <input id="{{ uniqueId }}-{{ \$index }}" type="checkbox" ng-model="l.selected" ng-change="collectValues()"/>
        <label for="{{ uniqueId }}-{{ \$index }}">
            {{ l.display }}
        </label>
    </li>
</ul>
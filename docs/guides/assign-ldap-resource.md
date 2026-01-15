# Guide: Assigner la ressource LDAP aux utilisateurs via GUI MidPoint

## Étape 1: Se connecter à MidPoint

1. Ouvrir http://localhost:8080/midpoint
2. Login: administrator / 5ecr3t

## Étape 2: Vérifier la ressource LDAP

1. Menu: **Configuration** > **Repository objects** > **Resources**
2. Cliquer sur **OpenLDAP Kerialis**
3. Cliquer sur **Test connection** - doit être vert ✅

## Étape 3: Assigner la ressource à un utilisateur

### Méthode 1: Assignment manuel (pour un ou deux utilisateurs)

1. Menu: **Users** > **All users**
2. Cliquer sur un utilisateur (ex: jdupont)
3. Onglet **Projections**
4. Cliquer sur **Assign account** (bouton bleu)
5. Sélectionner **OpenLDAP Kerialis**
6. Cliquer sur **Assign**
7. Cliquer sur **Save** en bas

Répéter pour chaque utilisateur.

### Méthode 2: Object Template avec auto-assignment (automatique)

1. Menu: **Configuration** > **Repository objects** > **Object templates**
2. Cliquer sur **New object template** (ou chercher l'existant)
3. Xml:
\`\`\`xml
<?xml version="1.0" encoding="UTF-8"?>
<objectTemplate oid="auto-ldap-assignment"
    xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
    xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
    
    <name>Auto LDAP Assignment</name>
    
    <mapping>
        <name>Auto-assign LDAP resource</name>
        <strength>strong</strength>
        <source>
            <path>$user/name</path>
        </source>
        <expression>
            <assignmentTargetSearch>
                <targetType>c:ResourceType</targetType>
                <oid>8a83b1a4-be18-11d0-a765-123478563412</oid>
            </assignmentTargetSearch>
        </expression>
        <target>
            <path>assignment</path>
        </target>
    </mapping>
    
</objectTemplate>
\`\`\`

4. **Save**

5. Appliquer le template:
   - Menu: **Configuration** > **System configuration**
   - Onglet **Basic**
   - Section **Default object policy configuration**
   - Ajouter:
\`\`\`xml
<objectTemplate>
    <type>UserType</type>
    <objectTemplateRef oid="auto-ldap-assignment"/>
</objectTemplate>
\`\`\`
   - **Save**

6. Recomputer les utilisateurs existants:
   - Menu: **Users** > **All users**
   - Cocher tous les utilisateurs (sauf administrator)
   - Menu **Action** > **Recompute**

## Étape 4: Vérifier la synchronisation

1. Retourner sur un utilisateur
2. Onglet **Projections**
3. Devrait voir: **uid=jdupont,ou=people,dc=kerialis,dc=local**

4. Vérifier dans LDAP:
\`\`\`powershell
docker exec iam-ldap ldapsearch -x -LLL -H ldap://localhost -b "dc=kerialis,dc=local" -D "cn=admin,dc=kerialis,dc=local" -w admin "(uid=jdupont)" dn cn mail
\`\`\`

5. Vérifier dans phpLDAPadmin: http://localhost:8081
   - Login: cn=admin,dc=kerialis,dc=local / admin
   - Naviguer: dc=kerialis,dc=local > ou=people
   - Voir les utilisateurs

## Méthode 3: Script REST API direct (le plus rapide)

Voir le script PowerShell ci-dessous qui fait directement les appels REST.

---

**Note**: La méthode 1 (assignment manuel) est la plus rapide pour tester immédiatement.

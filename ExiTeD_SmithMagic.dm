<module>
    <!-- Information sur le module -->
    <header>
        <!-- Nom affiché dans la liste des modules -->
        <name>SmithMagic</name>        
        <!-- Version du module -->
        <version>1.0</version>
        <!-- Dernière version de dofus pour laquelle ce module fonctionne -->
        <dofusVersion>2.3.5</dofusVersion>
        <!-- Auteur du module -->
        <author>ExiTeD</author>
        <!-- Courte description -->
        <shortDescription>Forgemagie assistée</shortDescription>
        <!-- Description détaillée -->
        <description>Ce module permet de d'utiliser une interface plus détaillée et plus pratique afin d'améliorer les objets</description>
	</header>

    <!-- Liste des interfaces du module, avec nom de l'interface, nom du fichier squelette .xml et nom de la classe script d'interface -->
    <uis>
        <ui name="smithmagic" file="xml/smithmagic.xml" class="ui::SmithMagicUi" />
    </uis>
    
    <script>SmithMagic.swf</script>
</module>

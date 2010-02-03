##
## Base template for sharing an item. Template expects the following parameters:
## (a) item - item to be shared.
##

<%inherit file="/base.mako"/>

<%namespace file="./display_common.mako" import="*" />

##
## Page methods.
##

<%def name="title()">
    Sharing and Publishing ${get_class_display_name( item.__class__ )} '${get_item_name( item )}'
</%def>

<%def name="stylesheets()">
    ${parent.stylesheets()}
    <style>
        div.indent
        {
            margin-left: 1em;
        }
        input.action-button
        {
            margin-left: 0;
        }
    </style>
</%def>

<%def name="body()">
    <%
        #
        # Setup and variables needed for page.
        #
    
        # Get class name strings.
        item_class_name = get_class_display_name( item.__class__ ) 
        item_class_name_lc = item_class_name.lower()
        item_class_plural_name = get_class_plural_display_name( item.__class__ )
        item_class_plural_name_lc = item_class_plural_name.lower()
    %>
    <% item_name = get_item_name(item) %>

    <h2>Sharing and Publishing ${item_class_name} '${item_name}'</h2>

    ## Require that user have a public username before sharing or publishing an item.
    %if trans.get_user().username is None or trans.get_user().username is "":
        To make a ${item_class_name_lc} accessible via link or publish it, you must create a public username: 
        <p>
        <form action="${h.url_for( action='set_public_username', id=trans.security.encode_id( item.id ) )}"     
                method="POST">
            <div class="form-row">
                <label>Public Username:</label>
                <div class="form-row-input">
                    <input type="text" name="username" size="40"/>
                </div>
            </div>
            <div style="clear: both"></div>
            <div class="form-row">
                <input class="action-button" type="submit" name="Set Username" value="Set Username"/>
            </div>
        </form>
    %else:
        ## User has a public username, so private sharing and publishing options.
        <div class="indent" style="margin-top: 2em">
        <h3>Making ${item_class_name} Accessible via Link and Publishing It</h3>
    
            <div>
                %if item.importable:
                    <% 
                        item_status = "accessible via link" 
                        if item.published:
                            item_status = item_status + " and published"    
                    %>
                    This ${item_class_name_lc} <strong>${item_status}</strong>. 
                    <div>
                        <p>Anyone can view and import this ${item_class_name_lc} by visiting the following URL:
                        <% url = h.url_for( action='display_by_username_and_slug', username=trans.get_user().username, slug=item.slug, qualified=True ) %>
                        <blockquote>
                            <a href="${url}" target="_top">${url}</a>
                        </blockquote>
        
                        %if item.published:
                            This ${item_class_name_lc} is publicly listed and searchable in Galaxy's <a href='${h.url_for( action='list_published' )}' target="_top">Published ${item_class_plural_name}</a> section.
                        %endif
                    </div>
        
                    <p>You can:
                    <div>
                    <form action="${h.url_for( action='sharing', id=trans.security.encode_id( item.id ) )}" 
                            method="POST">
                            %if not item.published:
                                ## Item is importable but not published. User can disable importable or publish.
                                <input class="action-button" type="submit" name="disable_link_access" value="Disable Access to ${item_class_name} Link">
                                <div class="toolParamHelp">Disables ${item_class_name_lc}'s link so that it is not accessible.</div>
                                <br>
                                <input class="action-button" type="submit" name="publish" value="Publish ${item_class_name}" method="POST">
                                <div class="toolParamHelp">Publishes the ${item_class_name_lc} to Galaxy's <a href='${h.url_for( action='list_published' )}' target="_top">Published ${item_class_plural_name}</a> section, where it is publicly listed and searchable.</div>

                            <br>
                            %else: ## item.published == True
                                ## Item is importable and published. User can unpublish or disable import and unpublish.
                                <input class="action-button" type="submit" name="unpublish" value="Unpublish ${item_class_name}">
                                <div class="toolParamHelp">Removes ${item_class_name_lc} from Galaxy's <a href='${h.url_for( action='list_published' )}' target="_top">Published ${item_class_plural_name}</a> section so that it is not publicly listed or searchable.</div>
                                <br>
                                <input class="action-button" type="submit" name="disable_link_access_and_unpubish" value="Disable Access to ${item_class_name} via Link and Unpublish">
                                <div class="toolParamHelp">Disables ${item_class_name_lc}'s link so that it is not accessible and removes ${item_class_name_lc} from Galaxy's <a href='${h.url_for( action='list_published' )}' target='_top'>Published ${item_class_plural_name}</a> section so that it is not publicly listed or searchable.</div>
                            %endif
                
                    </form>
                    </div>
   
                %else:
   
                    This ${item_class_name_lc} is currently restricted so that only you and the users listed below can access it. You can:
                    <p>
                    <form action="${h.url_for( action='sharing', id=trans.security.encode_id(item.id) )}" method="POST">
                        <input class="action-button" type="submit" name="make_accessible_via_link" value="Make ${item_class_name} Accessible via Link">
                        <div class="toolParamHelp">Generates a web link that you can share with other people so that they can view and import the ${item_class_name_lc}.</div>
        
                        <br>
                        <input class="action-button" type="submit" name="make_accessible_and_publish" value="Make ${item_class_name} Accessible and Publish" method="POST">
                        <div class="toolParamHelp">Makes the ${item_class_name_lc} accessible via link (see above) and publishes the ${item_class_name_lc} to Galaxy's <a href='${h.url_for( action='list_published' )}' target='_top'>Published ${item_class_plural_name}</a> section, where it is publicly listed and searchable.</div>
                    </form>
       
                %endif
            </div>

        <h3>Sharing ${item_class_name} with Specific Users</h3>

            <div>
                %if item.users_shared_with:

                    <p>
                        The following users will see this ${item_class_name_lc} in their ${item_class_name_lc} list and will be
                        able to run/view and import it.
                    </p>
            
                    <table class="colored" border="0" cellspacing="0" cellpadding="0" width="100%">
                        <tr class="header">
                            <th>Email</th>
                            <th></th>
                        </tr>
                        %for i, association in enumerate( item.users_shared_with ):
                            <% user = association.user %>
                            <tr>
                                <td>
                                    ${user.email}
                                    <a id="user-${i}-popup" class="popup-arrow" style="display: none;">&#9660;</a>
                                </td>
                                <td>
                                    <div popupmenu="user-${i}-popup">
                                    <a class="action-button" href="${h.url_for( action='sharing', id=trans.security.encode_id( item.id ), unshare_user=trans.security.encode_id( user.id ) )}">Unshare</a>
                                    </div>
                                </td>
                            </tr>    
                        %endfor
                    </table>
    
                    <p>
                    <a class="action-button" href="${h.url_for( action='share', id=trans.security.encode_id(item.id) )}">
                        <span>Share with another user</span>
                    </a>

                %else:

                    <p>You have not shared this ${item_class_name_lc} with any users.</p>
    
                    <a class="action-button" href="${h.url_for( action='share', id=trans.security.encode_id(item.id) )}">
                        <span>Share with a user</span>
                    </a>
                    <br>
    
                %endif
            </div>
        </div>
    %endif

    <p><br><br>
    <a href=${h.url_for( action="list" )}>Back to ${item_class_plural_name} List</a>
</%def>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.participante.RParticipanteComentario" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="org.apache.cayenne.query.Ordering" %>
<%@ page import="org.apache.cayenne.query.SortOrder" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ taglib prefix="tags" tagdir="/WEB-INF/tags" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  ~ Baseform
  ~ Copyright (C) 2018  Baseform
  ~
  ~ This program is free software: you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation, either version 3 of the License, or
  ~ (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program.  If not, see <https://www.gnu.org/licenses/>.
  --%>

<%
    Integer p = request.getParameter("page") != null ? Integer.valueOf(request.getParameter("page")) : null ;
    Long ts = request.getParameter("timestamp") != null ? Long.valueOf(request.getParameter("timestamp")) : null ;

    Integer rT = request.getParameter("responseTo") != null ? Integer.valueOf(request.getParameter("responseTo")) : null ;
    Integer rP = request.getParameter("rP") != null ? Integer.valueOf(request.getParameter("rP")) : null ;

    String type = request.getParameter("type");

    final Processo.GAMIFICATION_ACTIONS action = type.trim().toLowerCase().startsWith("tip") ? Processo.GAMIFICATION_ACTIONS.TIP : Processo.GAMIFICATION_ACTIONS.COMMENT;

    PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    Processo processo = pm.getProcess();
    final String currentSystem = pm.getSystemId(request);
    boolean open = true;
    Participante participante = pm.getParticipante();

    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
    DateFormat df = new SimpleDateFormat("dd MMMM yyyy - K:m a", Locale.US);
    List<RParticipanteComentario> commentList;
    DecimalFormat rounder = new DecimalFormat("#.##");

    int size = type.equalsIgnoreCase("comment") ? processo.getApprovedComments().size() : processo.getApprovedTips().size();
    if (p != null)
        commentList = processo.getCommentsAndTipsPaginated(p, pm.pagination, type, ts,participante, response);
    else
        commentList = processo.getNewApprovedCommentsAndTipsPaginated(type, ts);
%>
<% for (RParticipanteComentario comment : commentList) {  %>
<li class="comment  status<%= comment.getStatus() %>" data-id="<%= comment.getId() %>">
    <img src="<%= comment.getParticipante() != null && comment.getParticipante().getImagem() != null ? "./user_avatar?id="+comment.getParticipante().getImagem().getId() : "redesign_images/user.png" %>" alt="user" class="userImage">
    <div class="commentInfo">
        <% if (comment.getTitle().length() > 0) {%> <p class="commentTitle"><%= comment.getTitle() %></p><!--
                --><% }%><p class="commentName"><%= comment.getParticipante().getSafeNome()%></p><!--
                --><tags:userImgTag participant="<%=comment.getParticipante()%>"/><span class="date"><%= df.format(comment.getData()) %></span><!--
                -->
        <a download href="#" target="blank" class="description noAttachment"><%= comment.getComentario()%></a>
        <% if (comment.getFicheiro() != null && comment.getFicheiro().getSize() != null) {%>
        <% if (comment.getFicheiro().getMime().contains("image")) { %>
        <img src="/comment?id=<%= comment.getFicheiro().getId() %>" class="commentPhoto">
        <% }%>
        <a href="/comment?id=<%= comment.getFicheiro().getId()%>" target="blank" class="fileInfo"><%= comment.getFicheiro().getNomeFicheiro()%> - <%= "[" + ((comment.getFicheiro().getSize() / 1048576f) >= 1.0 ? rounder.format(comment.getFicheiro().getSize() / 1048576f) + "Mb]" : rounder.format(comment.getFicheiro().getSize() / 1024f) + "Kb]")%></a>
        <% }%>
        <% if (comment.getStatus() != RParticipanteComentario.APPROVED) { %>
        <span class="status">
                    <% if (comment.getStatus() == RParticipanteComentario.PENDING_APPROVAL) {%>
                        <%=PowerUtils.localizeKey("pending.approval",currentLangBundle,frontendDefaultBundle)%>
                    <% } else {%>
                        <%=PowerUtils.localizeKey("removed",currentLangBundle,frontendDefaultBundle)%>
                    <% }%>
                    </span>
        <% }%>
    </div><% if (comment.getStatus() == RParticipanteComentario.APPROVED) { %><!--
            --><div class="actionButtons">
    <% if (open) {%><a id="reply_<%= comment.getId() %>" data-id="<%= comment.getId() %>" data-count="<%= comment.getApprovedResponse().size() %>" class="actionLink reply"><%=PowerUtils.localizeKey("action.comment",currentLangBundle,frontendDefaultBundle)%> (<%= comment.getApprovedResponse().size()%>)</a><%}%><!--
            --><a id="like_<%= comment.getId() %>" class="actionLink like  enabled_<%= open %>" <% if (open && participante != null) {%>onclick="like(<%= comment.getId() %>)"<% }%>><%= comment.getLikes() %></a><!--
            --><div class="action share" data-extra="&cId=<%= comment.getId() %>">
    <svg class="actionSvg" enable-background="new 0 0 24 24" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="m19.801 15.601c-1.182 0-2.248.489-3.011 1.274l-8.445-4.223c.033-.213.056-.43.056-.651 0-.223-.022-.439-.056-.652l8.445-4.223c.764.785 1.829 1.274 3.011 1.274 2.319 0 4.199-1.88 4.199-4.2s-1.88-4.2-4.199-4.2c-2.32 0-4.2 1.881-4.2 4.2 0 .223.022.439.056.652l-8.446 4.223c-.763-.785-1.829-1.274-3.011-1.274-2.319 0-4.2 1.88-4.2 4.2 0 2.319 1.881 4.199 4.2 4.199 1.182 0 2.248-.489 3.011-1.274l8.445 4.223c-.033.213-.056.43-.056.652 0 2.319 1.88 4.199 4.2 4.199s4.2-1.88 4.2-4.199c0-2.321-1.88-4.2-4.199-4.2z" fill="#36c"/></svg>
    <a href="#" class="actionName <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("share",currentLangBundle,frontendDefaultBundle,true) %></a>
    <jsp:include page="sharePopup.jsp" />
</div>
</div>
    <% }%>
    <div class="comments replyBox hidden">
        <% if (true) {%>
        <form action="./?<%=RequestParameters.COMENTAR%>=<%= comment.getId() %>" enctype="multipart/form-data" method="post" accept-charset="utf-8" autocomplete="off">
            <input type="hidden" name="process" class="pId" value="<%=processo.getId()%>"/>
            <input type="hidden" name="responseTo" class="cId" value="<%=comment.getId()%>"/>
            <input type="hidden" name="loginEmail"/>
            <input type="hidden" name="loginPassword"/>
            <input type="hidden" name="isReply" value="true"/>
            <input type="text" name="title" class="boxCommentTitle" placeholder="<%=PowerUtils.localizeKey("write.comment.title",currentLangBundle,frontendDefaultBundle)%>">
            <textarea class="boxComment" name="<%=RequestParameters.COMENTARIO%>" placeholder="<%=PowerUtils.localizeKey("write.comment",currentLangBundle,frontendDefaultBundle)%>"></textarea><!--
                    --><div class="actions">
            <label><input  type="file" name="photo" accept="image/*"  onchange="$(this).closest('form').find('.photoName').html($(this).val().replace('C:\\fakepath\\',''));"/></label>
            <span class="photoName"> </span>
            <a href="#" class="sendComment" data-participante="<%= participante != null %>"><%=PowerUtils.localizeKey("submit",currentLangBundle,frontendDefaultBundle)%></a>
        </div>
        </form>
        <% }%>
        <ul class="commentList appendResponses">
            <% Integer responsePage = 0;
                List<RParticipanteComentario> replies = comment.getResponsePaginated(responsePage, pm.pagination, participante, response, ts);
                new Ordering(RParticipanteComentario.DATA_PROPERTY, SortOrder.DESCENDING_INSENSITIVE).orderList(replies);
                Integer k = 0;
                for (RParticipanteComentario reply : replies) {  %>
            <li class="comment status<%= reply.getStatus() %> <% if (participante != null && k == 0) { %>firstComment<% }k++;%>"  data-id="<%= reply.getId()%>">
                <img src="<%= reply.getParticipante() != null && reply.getParticipante().getImagem() != null ? "./user_avatar?id="+reply.getParticipante().getImagem().getId() : "redesign_images/user.png" %>" alt="user" class="userImage">
                <div class="commentInfo">
                    <% if (reply.getTitle().length() > 0) {%> <p class="commentTitle"><%= reply.getTitle() %></p><!--
                            --><% }%><p class="commentName"><%= reply.getParticipante().getSafeNome()%></p><!--
                        --><tags:userImgTag participant="<%=reply.getParticipante()%>"/><span class="date"><%= df.format(reply.getData()) %></span>
                    <a download href="#" target="blank" class="description noAttachment"><%= reply.getComentario()%></a>
                    <% if (reply.getFicheiro() != null && reply.getFicheiro().getSize() != null) {%>
                    <% if (reply.getFicheiro().getMime().contains("image")) { %>
                    <img src="/comment?id=<%= reply.getFicheiro().getId() %>" class="commentPhoto">
                    <% }%>
                    <a href="/comment?id=<%= reply.getFicheiro().getId()%>" target="blank" class="fileInfo"><%= reply.getFicheiro().getNomeFicheiro()%> - <%= "[" + ((reply.getFicheiro().getSize() / 1048576f) >= 1.0 ? rounder.format(reply.getFicheiro().getSize() / 1048576f) + "Mb]" : rounder.format(reply.getFicheiro().getSize() / 1024f) + "Kb]")%></a>
                    <% }%>
                    <% if (reply.getStatus() != RParticipanteComentario.APPROVED) { %>
                    <span class="status">
                            <% if (reply.getStatus() == RParticipanteComentario.PENDING_APPROVAL) {%>
                                <%=PowerUtils.localizeKey("pending.approval",currentLangBundle,frontendDefaultBundle)%>
                            <% } else {%>
                                <%=PowerUtils.localizeKey("removed",currentLangBundle,frontendDefaultBundle)%>
                            <% }%>
                            </span>
                    <% }%>
                </div><% if (reply.getStatus() == RParticipanteComentario.APPROVED) { %><!--
                --><div class="actionButtons">
                <a id="like_<%= reply.getId() %>" class="actionLink like enabled_<%= open %>" <% if (open && participante != null) {%>onclick="like(<%= reply.getId() %>)"<% }%>><%= reply.getLikes() %></a><!--
                        --><div class="action share" data-extra="&cId=<%= comment.getId() %>&rId=<%= reply.getId() %>">
                <svg class="actionSvg" enable-background="new 0 0 24 24" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="m19.801 15.601c-1.182 0-2.248.489-3.011 1.274l-8.445-4.223c.033-.213.056-.43.056-.651 0-.223-.022-.439-.056-.652l8.445-4.223c.764.785 1.829 1.274 3.011 1.274 2.319 0 4.199-1.88 4.199-4.2s-1.88-4.2-4.199-4.2c-2.32 0-4.2 1.881-4.2 4.2 0 .223.022.439.056.652l-8.446 4.223c-.763-.785-1.829-1.274-3.011-1.274-2.319 0-4.2 1.88-4.2 4.2 0 2.319 1.881 4.199 4.2 4.199 1.182 0 2.248-.489 3.011-1.274l8.445 4.223c-.033.213-.056.43-.056.652 0 2.319 1.88 4.199 4.2 4.199s4.2-1.88 4.2-4.199c0-2.321-1.88-4.2-4.199-4.2z" fill="#36c"/></svg>
                <a href="#" class="actionName <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("share",currentLangBundle,frontendDefaultBundle,true) %></a>
                <jsp:include page="sharePopup.jsp" />
            </div>
            </div>
                <% }%>
            </li>
            <% } %>
            <% if (replies.size() == pm.pagination) { %>
            <a href="#" class="loadMoreC loadMoreResponses" data-id="<%= comment.getId() %>" data-page="<%= responsePage + 1 %>">Load More...</a>
            <% } %>
        </ul>
    </div>
</li>
    <% }%>

<%--<% if (size != 0)  {%>--%>
<%--<ul class="pagination" data-type="<%= type %>">--%>
    <%--<% if (p != 1) { %>--%>
    <%--<li class="page back" data-page="<%= p - 1%>"><a href="#"><</a></li>--%>
    <%--<% } %>--%>
    <%--<% if (p - 1 != 1 && p != 1) { %>--%>
    <%--<li class="page first" data-page="1"><a href="#">1... </a></li>--%>
    <%--<% } %>--%>
    <%--<% int k = 0;--%>
    <%--int offset = 1;--%>
    <%--if (p == 1) offset = 0;--%>
    <%--if (p == Math.ceil(size / PowerPubManager.pagination.doubleValue())) offset = 2;--%>
        <%--for (int i = p - offset; i <= Math.ceil(size / PowerPubManager.pagination.doubleValue()); i++){%>--%>
            <%--<li class="page <% if (p == i) {%> currentPage <% }%>" data-page="<%= i %>"><a href="#"><%= i %></a></li>--%>
        <%--<% k++; if (k==3) break; };%>--%>
    <%--<% if (p + 1 !=  Math.ceil(size / PowerPubManager.pagination.doubleValue()) && p !=  Math.ceil(size / PowerPubManager.pagination.doubleValue())) {%>--%>
        <%--<li class="page last" data-page="<%=  Double.valueOf(Math.ceil(size / PowerPubManager.pagination.doubleValue())).intValue() %>"><a href="#"> ...<%= Double.valueOf(Math.ceil(size / PowerPubManager.pagination.doubleValue())).intValue() %></a></li>--%>
    <%--<% } %>--%>
    <%--<% if (p != Math.ceil(size / PowerPubManager.pagination.doubleValue())) { %>--%>
    <%--<li class="page next" data-page="<%= p + 1%>"><a href="#">></a></li>--%>
    <%--<% } %>--%>
<%--</ul>--%>
<%--<% }%>--%>
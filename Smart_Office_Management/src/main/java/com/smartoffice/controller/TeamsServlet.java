package com.smartoffice.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.smartoffice.dao.TeamDAO;
import com.smartoffice.dao.UserDao;
import com.smartoffice.model.Team;
import com.smartoffice.model.User;

@SuppressWarnings("serial")
@WebServlet("/teams")
public class TeamsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            res.sendRedirect(req.getContextPath() + "/index.html");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"admin".equalsIgnoreCase(role)) {
            res.sendRedirect(req.getContextPath() + "/index.html");
            return;
        }

        String action = req.getParameter("action");
        if ("getTeam".equals(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    Team team = TeamDAO.getTeamById(Integer.parseInt(idStr));
                    req.setAttribute("team", team);
                } catch (NumberFormatException ignored) {}
            }
        }

        List<Team> teams = TeamDAO.getAllTeams();
        List<User> allUsers = UserDao.getAllUsers();
        List<User> managers = new ArrayList<>();
        List<User> employees = new ArrayList<>();
        for (User u : allUsers) {
            String r = u.getRole() != null ? u.getRole().toLowerCase() : "";
            if ((r.startsWith("man") || "manager".equals(r)) && "active".equalsIgnoreCase(u.getStatus()))
                managers.add(u);
            else if ("user".equalsIgnoreCase(u.getRole()) && "active".equalsIgnoreCase(u.getStatus()))
                employees.add(u);
        }

        Set<String> assignedUsernames = TeamDAO.getEmailsInAnyTeam();
        req.setAttribute("teams", teams);
        req.setAttribute("managers", managers);
        req.setAttribute("employees", employees);
        req.setAttribute("assignedUsernames", assignedUsernames);
        req.getRequestDispatcher("adminTeams.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            res.sendRedirect(req.getContextPath() + "/index.html");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"admin".equalsIgnoreCase(role)) {
            res.sendRedirect(req.getContextPath() + "/index.html");
            return;
        }

        String action = req.getParameter("action");
        String admin = (String) session.getAttribute("username");

        if ("create".equals(action)) {
            String name = req.getParameter("teamName");
            String managerUsername = req.getParameter("managerUsername");
            if (admin == null || admin.isEmpty()) {
                session.setAttribute("teamsError", "Session expired. Please log in again.");
            } else if (name != null && !name.trim().isEmpty() && managerUsername != null && !managerUsername.isEmpty()) {
                if (TeamDAO.teamNameExists(name.trim())) {
                    session.setAttribute("teamsError", "Team name already exists.");
                } else if (TeamDAO.createTeam(name.trim(), managerUsername, admin)) {
                    session.setAttribute("teamsSuccess", "Team created successfully.");
                } else {
                    session.setAttribute("teamsError", "Failed to create team. Run database/fix-teams-fk.sql in MySQL if you have schema issues.");
                }
            } else {
                session.setAttribute("teamsError", "Team name and manager are required.");
            }
        } else if ("addMember".equals(action)) {
            String teamIdStr = req.getParameter("teamId");
            String[] usernames = req.getParameterValues("username");
            if (usernames == null) usernames = req.getParameterValues("email");
            if (teamIdStr != null && usernames != null && usernames.length > 0) {
                try {
                    int teamId = Integer.parseInt(teamIdStr);
                    int added = 0, skipped = 0;
                    for (String username : usernames) {
                        if (username == null || username.trim().isEmpty()) continue;
                        username = username.trim();
                        if (TeamDAO.addMemberToTeam(teamId, username)) {
                            added++;
                        } else {
                            skipped++;
                        }
                    }
                    if (added > 0) {
                        session.setAttribute("teamsSuccess", added + " employee(s) added to team.");
                    }
                    if (skipped > 0 && added == 0) {
                        session.setAttribute("teamsError", "Selected employee(s) may already be in the team.");
                    } else if (skipped > 0) {
                        session.setAttribute("teamsSuccess", added + " added. " + skipped + " already in team.");
                    }
                } catch (NumberFormatException ignored) {
                    session.setAttribute("teamsError", "Invalid team.");
                }
            } else {
                session.setAttribute("teamsError", "Select a team and at least one employee.");
            }
        } else if ("removeMember".equals(action)) {
            String teamIdStr = req.getParameter("teamId");
            String username = req.getParameter("username");
            if (username == null) username = req.getParameter("email");
            if (teamIdStr != null && username != null) {
                try {
                    TeamDAO.removeMemberFromTeam(Integer.parseInt(teamIdStr), username);
                    session.setAttribute("teamsSuccess", "Employee removed from team.");
                } catch (NumberFormatException ignored) {}
            }
        } else if ("updateManager".equals(action)) {
            String teamIdStr = req.getParameter("teamId");
            String managerUsername = req.getParameter("managerUsername");
            if (teamIdStr != null && managerUsername != null && !managerUsername.isEmpty()) {
                try {
                    if (TeamDAO.updateTeamManager(Integer.parseInt(teamIdStr), managerUsername)) {
                        session.setAttribute("teamsSuccess", "Manager updated.");
                    } else {
                        session.setAttribute("teamsError", "Failed to update manager.");
                    }
                } catch (NumberFormatException ignored) {}
            }
        } else if ("delete".equals(action)) {
            String teamIdStr = req.getParameter("teamId");
            if (teamIdStr != null) {
                try {
                    if (TeamDAO.deleteTeam(Integer.parseInt(teamIdStr))) {
                        session.setAttribute("teamsSuccess", "Team deleted.");
                    } else {
                        session.setAttribute("teamsError", "Failed to delete team.");
                    }
                } catch (NumberFormatException ignored) {}
            }
        }

        res.sendRedirect(req.getContextPath() + "/teams");
    }
}

package com.digitalforensics.dao;

import com.digitalforensics.model.InvestigationCase;
import com.digitalforensics.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CaseDAO {
    public long create(InvestigationCase c) throws Exception {
        String sql = "INSERT INTO cases(case_code,case_name,description,status,created_by) VALUES(?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, c.getCaseCode());
            ps.setString(2, c.getCaseName());
            ps.setString(3, c.getDescription());
            ps.setString(4, c.getStatus());
            ps.setLong(5, c.getCreatedBy());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (!rs.next()) throw new SQLException("Case ID was not generated");
                return rs.getLong(1);
            }
        }
    }

    public List<InvestigationCase> findAll() throws Exception {
        String sql = "SELECT c.id,c.case_code,c.case_name,c.description,c.status,c.created_by,c.created_at,c.updated_at,u.full_name "
                   + "FROM cases c JOIN users u ON u.id=c.created_by ORDER BY c.created_at DESC";
        List<InvestigationCase> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public InvestigationCase findById(long id) throws Exception {
        String sql = "SELECT c.id,c.case_code,c.case_name,c.description,c.status,c.created_by,c.created_at,c.updated_at,u.full_name "
                   + "FROM cases c JOIN users u ON u.id=c.created_by WHERE c.id=?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? map(rs) : null; }
        }
    }

    private InvestigationCase map(ResultSet rs) throws SQLException {
        InvestigationCase c = new InvestigationCase();
        c.setId(rs.getLong("id"));
        c.setCaseCode(rs.getString("case_code"));
        c.setCaseName(rs.getString("case_name"));
        c.setDescription(rs.getString("description"));
        c.setStatus(rs.getString("status"));
        c.setCreatedBy(rs.getLong("created_by"));
        c.setCreatedByName(rs.getString("full_name"));
        Timestamp created = rs.getTimestamp("created_at");
        Timestamp updated = rs.getTimestamp("updated_at");
        if (created != null) c.setCreatedAt(created.toLocalDateTime());
        if (updated != null) c.setUpdatedAt(updated.toLocalDateTime());
        return c;
    }

    public long count() throws Exception {
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM cases"); ResultSet rs = ps.executeQuery()) {
            rs.next(); return rs.getLong(1);
        }
    }
}

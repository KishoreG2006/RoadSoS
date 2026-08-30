const { supabaseAdmin } = require('../config/supabase');

const inMemorySosReports = [];

/**
 * 1. Process Incoming DTN SOS Bundle
 * POST /api/sos/dtn-gateway
 */
const receiveDtnBundle = async (req, res) => {
  try {
    const bundle = req.body;
    const bundleId = bundle.bundleId || bundle.bundle_id || `SOS-${Date.now()}`;

    const report = {
      bundle_id: bundleId,
      message_type: bundle.messageType || bundle.message_type || 'ACCIDENT',
      severity: bundle.severity || 'HIGH',
      latitude: bundle.latitude || 0.0,
      longitude: bundle.longitude || 0.0,
      hop_count: bundle.hopCount || bundle.hop_count || 0,
      ttl: bundle.ttl || 3600,
      message: bundle.message || 'Emergency SOS Alert',
      received_at: new Date().toISOString()
    };

    try {
      await supabaseAdmin.from('sos_reports').insert(report);
    } catch (_) {
      inMemorySosReports.push(report);
    }

    console.log(`[DTN Gateway] Received SOS Bundle: ${bundleId} (Severity: ${report.severity}, Hops: ${report.hop_count})`);

    return res.status(200).json({
      success: true,
      message: 'DTN SOS Bundle received and logged successfully',
      bundle_id: bundleId
    });
  } catch (error) {
    console.error('DTN Gateway Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error processing DTN SOS bundle',
      error: error.message
    });
  }
};

/**
 * 2. Get All SOS Reports
 * GET /api/sos/reports
 */
const getSosReports = async (req, res) => {
  try {
    let reports = [];
    try {
      const { data } = await supabaseAdmin
        .from('sos_reports')
        .select('*')
        .order('received_at', { ascending: false });
      if (data) reports = data;
    } catch (_) {
      reports = inMemorySosReports;
    }

    return res.status(200).json({
      success: true,
      count: reports.length,
      reports: reports
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Server error retrieving SOS reports',
      error: error.message
    });
  }
};

module.exports = {
  receiveDtnBundle,
  getSosReports
};

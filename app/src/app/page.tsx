'use client';

import { useEffect, useState } from 'react';
import { AppLayout } from '@/components/AppLayout';
import { KPICard } from '@/components/KPICard';
import { Chart } from '@/components/Chart';
import { DataTable } from '@/components/DataTable';
import { AskAI } from '@/components/AskAI';
import { ActionMemo } from '@/components/ActionMemo';
import { GeoMap } from '@/components/GeoMap';
import { ArchitectureDiagram } from '@/components/ArchitectureDiagram';

interface DemoNarrative {
  title: string;
  duration: string;
  thesis: string;
  tabs: any[];
}

export default function HomePage() {
  const [narrative, setNarrative] = useState<DemoNarrative | null>(null);
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    fetch('/demo_narrative.json')
      .then((r) => r.json())
      .then(setNarrative)
      .catch(() => {});
    fetch('/api/data')
      .then((r) => r.json())
      .then(setData)
      .catch(() => {});
  }, []);


  // KPI values come from /api/data, which reads CURATED.KPI_SUMMARY. The literal
  // stays as a fallback so the card still renders if the API is unavailable.
  const kpiVal = (title: string, fallback: string): string =>
    (data?.kpiCards as { title: string; value: string }[] | undefined)
      ?.find((k) => k.title === title)?.value ?? fallback;

  const title = narrative?.title || 'SEA AWS Demo';

  const executiveCockpit = (
    <div className="space-y-6">
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KPICard title="Yield Forecast" value={kpiVal('Yield Forecast', '4.8 T/rai')} status="neutral" />
        <KPICard title="Water Stress Alerts" value={kpiVal('Water Stress Alerts', '23')} status="warning" />
        <KPICard title="Pest Risk Zones" value={kpiVal('Pest Risk Zones', '7')} status="danger" />
        <KPICard title="Monitored Farms" value={kpiVal('Monitored Farms', '1,450')} status="neutral" />
      </div>
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <div className="lg:col-span-1">
          <GeoMap
            country="thailand"
            labels={{ entity: 'Provinces', event: 'Sensor Readings', alert: 'Field Alerts' }}
            regions={data?.regions}
            markers={[{"label": "Nakhon Ratchasima", "value": "Cassava: 4.2 T/rai", "color": "green", "size": "lg"}, {"label": "Chiang Rai", "value": "Rice: PEST ALERT", "color": "red", "size": "md"}, {"label": "Udon Thani", "value": "Sugarcane: water stress", "color": "amber", "size": "md"}, {"label": "Khon Kaen", "value": "Cassava: 4.8 T/rai", "color": "green", "size": "md"}]}
            routes={[]}
            title="Geographic Overview"
            height={400}
          />
        </div>
        <div className="lg:col-span-1 grid grid-cols-1 gap-4">
      <div className="grid grid-cols-1 gap-4 grid-cols-1">
        <Chart
          data={data?.timeseries || [{ period: 'Jan', value: 112 }, { period: 'Feb', value: 118 }, { period: 'Mar', value: 135 }, { period: 'Apr', value: 148 }, { period: 'May', value: 156 }, { period: 'Jun', value: 142 }, { period: 'Jul', value: 138 }, { period: 'Aug', value: 151 }, { period: 'Sep', value: 144 }, { period: 'Oct', value: 132 }, { period: 'Nov', value: 121 }, { period: 'Dec', value: 115 }]}
          type="line"
          xKey="period"
          yKeys={[{ key: 'value', name: 'Tonnes/Rai' }]}
          title="Crop Yield Trend (Monthly)"
        />
        <Chart
          data={data?.categories || [{ category: 'North', count: 82 }, { category: 'Central', count: 74 }, { category: 'South', count: 91 }, { category: 'Highland', count: 68 }, { category: 'Coastal', count: 77 }]}
          type="bar"
          xKey="category"
          yKeys={[{ key: 'count', name: '฿/Rai' }]}
          title="Input Cost by Province"
        />
      </div>
        </div>
      </div>
      <DataTable
        columns={[
          { key: 'id', header: '#' },
          { key: 'name', header: 'Province' },
          { key: 'region', header: 'Region' },
          { key: 'status', header: 'Crop Health' },
          { key: 'm1', header: 'Yield (T/Rai)' },
          { key: 'm2', header: 'Pest Risk Zones' },
          { key: 'm3', header: 'Soil Moisture' },
          { key: 'events', header: 'Sensor Readings' },
          { key: 'alerts', header: 'Field Alerts' },
        ]}
        data={data?.entities || []}
        title="Farm Performance by Province"
      />
    </div>
  );

  const domainTab1 = (
    <div className="space-y-6">
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <KPICard title="Soil Moisture Avg" value={kpiVal('Soil Moisture Avg', '42%')} />
        <KPICard title="Fertilizer Efficiency" value={kpiVal('Fertilizer Efficiency', '87%')} />
        <KPICard title="Days to Harvest" value={kpiVal('Days to Harvest', '34')} />
      </div>
      <Chart
        data={data?.detail || [{ x: 'Mon', y: 24 }, { x: 'Tue', y: 28 }, { x: 'Wed', y: 22 }, { x: 'Thu', y: 31 }, { x: 'Fri', y: 26 }, { x: 'Sat', y: 19 }, { x: 'Sun', y: 23 }]}
        type="area"
        xKey="x"
        yKeys={[{ key: 'y', name: 'NDVI' }]}
        title="NDVI Index by Region"
        height={400}
      />
    </div>
  );

  const domainTab2 = (
    <div className="space-y-6">
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <Chart
          data={data?.breakdown || [{ label: 'Zone North', value: 35 }, { label: 'Zone Central', value: 28 }, { label: 'Zone South', value: 22 }, { label: 'Zone East', value: 15 }]}
          type="pie"
          xKey="label"
          yKeys={[{ key: 'value', name: '฿ Return/฿ Invested' }]}
          title="ROI by Intervention Type"
        />
        <ActionMemo
          persona={{ name: 'Prasert Kaewmanee', role: 'Agronomist Lead' }}
          context={{}}
          onGenerate={async () => {
            const memos = [
              {
                subject: 'Urgent: Operational Action Required',
                body: `Dear Leadership Team,\n\nBased on our analysis of the latest operational data, I am writing to recommend immediate action on the following critical items.\n\nKey Findings:\n- Performance metrics indicate a deviation from target KPIs in several areas\n- Predictive models suggest these trends will continue without intervention\n- Estimated impact: 12-15% improvement in efficiency if addressed within 2 weeks\n\nI recommend we schedule a review meeting this week to align on next steps.\n\nBest regards`,
                urgency: 'HIGH' as const,
                actions: ['Deploy irrigation to Nakhon Ratchasima drought zone', 'Apply pesticide in Chiang Rai pest cluster', 'Schedule soil amendment in Udon Thani'],
              },
              {
                subject: 'Weekly Performance Summary & Recommendations',
                body: `Dear Team,\n\nPlease find below the AI-generated weekly performance summary.\n\nHighlights:\n- Overall performance trending 8% above quarterly targets\n- Three areas identified for optimization with potential 20% cost savings\n- New anomaly patterns detected that warrant monitoring\n\nRecommended next steps are outlined below. Please review and confirm priority assignments by end of week.\n\nRegards`,
                urgency: 'MEDIUM' as const,
                actions: ['Deploy irrigation to Nakhon Ratchasima drought zone', 'Apply pesticide in Chiang Rai pest cluster', 'Schedule soil amendment in Udon Thani'],
              },
              {
                subject: 'Strategic Initiative: Data-Driven Optimization',
                body: `Dear Stakeholders,\n\nOur AI analysis has identified a significant opportunity for operational optimization.\n\nExecutive Summary:\n- Current utilization rate: 78% (target: 90%)\n- Root cause analysis points to 3 primary factors\n- Projected ROI of recommended changes: 2.4x within 6 months\n\nThe attached data supports a phased implementation approach starting with the highest-impact items.\n\nPlease advise on scheduling a planning session.\n\nBest regards`,
                urgency: 'HIGH' as const,
                actions: ['Deploy irrigation to Nakhon Ratchasima drought zone', 'Apply pesticide in Chiang Rai pest cluster', 'Schedule soil amendment in Udon Thani'],
              },
            ];
            return memos[Math.floor(Math.random() * memos.length)];
          }}
        />
      </div>
    </div>
  );

  const askAiTab = (
    <div className="h-[600px]">
      <AskAI
        title="Ask AI"
        sampleQuestions={[
          'Which farms have the lowest predicted yield this season?',
          'Show water stress correlation with yield in Isaan',
          'What interventions give the best ROI for cassava?',
        ]}
        mode="sql"
        onSubmit={async (question, mode) => {
          return {
            answer: `[Demo Mode] Response to: "${question}" (${mode} mode). Connect to Snowflake for live data.`,
            sql: mode === 'sql' ? 'SELECT * FROM CURATED.SUMMARY LIMIT 10;' : undefined,
          };
        }}
      />
    </div>
  );

  const architectureTab = (
    <ArchitectureDiagram
      snowflakeFeatures={['Dynamic Tables (5-min refresh)', 'ML Functions (Forecast + Anomaly)', 'Cortex Search + Agent', 'Semantic View + Intelligence', 'Alerts + Notifications']}
      awsServices={[{ name: 'Amazon S3', role: 'Strategy Docs' }, { name: 'Amazon S3 + Kinesis', role: 'Integration' }, { name: 'Amazon SNS', role: 'Integration' }, { name: 'Amazon QuickSight + Q', role: 'Integration' }]}
    />
  );

  const tabs = [
    { id: 'executive-cockpit', label: 'Executive Cockpit', icon: '📊', content: executiveCockpit },
    { id: 'domain-1', label: 'Crop Analytics', icon: '📈', content: domainTab1 },
    { id: 'domain-2', label: 'Intervention Planner', icon: '⚡', content: domainTab2 },
    { id: 'ask-ai', label: 'Ask AI', icon: '🤖', content: askAiTab },
    { id: 'architecture', label: 'Architecture & Data', icon: '🏗️', content: architectureTab },
  ];

  return (
    <AppLayout
      title={title}
      tabs={tabs}
      narrative={narrative}
    />
  );
}

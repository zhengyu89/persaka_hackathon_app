import {
  CalendarClock,
  ClipboardCheck,
  Gauge,
  Github,
  Headset,
  KeyRound,
  Layers,
  Mail,
  ScrollText,
  ShieldCheck,
  Smartphone,
  Sparkles,
  Trophy,
  Users,
  Workflow,
  type LucideIcon,
} from "lucide-react";

import logo from "../assets/images/hackathon.png";
import productPhone from "../assets/images/Product_Image.png";
import organiserDashboard from "../assets/images/Organiser_dashboard.png";
import teamCode from "../assets/images/Team_Code.png";
import submissionHub from "../assets/images/SubmissionHub.png";
import teamScoring from "../assets/images/Team_Scoring.png";
import leaderboard from "../assets/images/Leaderboard.png";
import tanZhengYu from "../assets/images/TanZhengYu.jpg";
import aiman from "../assets/images/Aiman.png";
import aidil from "../assets/images/Aidil.jpg";
import omer from "../assets/images/Omer.jpg";

import type {
  Benefit,
  ContactLink,
  Feature,
  NavItem,
  Screenshot,
  TeamMember,
} from "./types";

export const product = {
  name: "Persaka Hackathon App",
  shortName: "Persaka Hackathon",
  logo,
  productPhone,
  tagline: "Run your whole hackathon from one app.",
  // Why people should use it — value, not just features.
  valueProposition:
    "Persaka Hackathon brings teams, registration, submissions, judging, and live results into a single mobile app — so participants stay focused on building and organisers stop drowning in spreadsheets and group chats.",
  platform: "Flutter (Android & iOS) with a Firebase backend",
  repository: "https://github.com/zhengyu89/persaka_hackathon_app",
  team: {
    name: "PaidRider",
  },
} as const;

export const navItems: NavItem[] = [
  { label: "Home", href: "#home" },
  { label: "Features", href: "#features" },
  { label: "App Screenshots", href: "#screenshots" },
  { label: "About", href: "#about" },
  { label: "Team", href: "#team" },
  { label: "Contact", href: "#contact" },
];

export const problems: { title: string; description: string; icon: LucideIcon }[] =
  [
    {
      title: "Tools scattered everywhere",
      description:
        "Registration forms, judging sheets, schedules, and announcements live across different apps, chats, and spreadsheets that nobody can keep in sync.",
      icon: Layers,
    },
    {
      title: "Manual, error-prone judging",
      description:
        "Collecting scorecards by hand and tallying them in spreadsheets is slow, hard to audit, and easy to get wrong under event-day pressure.",
      icon: ClipboardCheck,
    },
    {
      title: "Participants left guessing",
      description:
        "Teams struggle to find deadlines, submission links, and standings, so organisers spend the event answering the same questions over and over.",
      icon: Headset,
    },
  ];

export const solutions: { title: string; description: string; icon: LucideIcon }[] =
  [
    {
      title: "One mobile home base",
      description:
        "Authentication, teams, registration, submissions, judging, schedule, and the leaderboard all live in a single role-aware Flutter app.",
      icon: Smartphone,
    },
    {
      title: "Structured, fair scoring",
      description:
        "Judges score against shared rubric criteria — with optional anonymous judging and minimum-judge thresholds — so results are consistent and trustworthy.",
      icon: ShieldCheck,
    },
    {
      title: "Everyone stays in the loop",
      description:
        "Live schedule, announcements, and published standings keep participants informed in real time, cutting the flood of repetitive questions.",
      icon: Sparkles,
    },
  ];

export const features: Feature[] = [
  {
    name: "Role-aware dashboards",
    description:
      "A shared auth gate routes each person to the right home: participant, judge, or organiser.",
    benefit:
      "Everyone sees only what's relevant to them, so the app feels purpose-built for each role.",
    icon: Workflow,
    span: "wide",
  },
  {
    name: "Secure sign-in",
    description:
      "Email & password plus Google sign-in, with email verification and password recovery via Firebase Authentication.",
    benefit: "Accounts stay protected and recovery is painless.",
    icon: KeyRound,
  },
  {
    name: "Teams in seconds",
    description:
      "Create a team to get a shareable 8-character code, or join an existing team instantly with that code.",
    benefit: "Forming and finding teammates takes moments, not messages.",
    icon: Users,
  },
  {
    name: "Submission hub",
    description:
      "Team leaders save repository and demo-video links per hackathon, with deadline enforcement built in.",
    benefit: "No more lost links or late, mis-routed submissions.",
    icon: ScrollText,
  },
  {
    name: "Rubric-based judging",
    description:
      "Judges open assigned teams and submit scorecards against organiser-defined criteria, with optional anonymous judging.",
    benefit: "Scoring is fair, consistent, and easy to defend.",
    icon: ClipboardCheck,
  },
  {
    name: "Live leaderboard & results",
    description:
      "Organisers publish or hide live standings and reveal final-results snapshots that respect minimum-judge rules.",
    benefit: "Teams see where they stand the moment results go live.",
    icon: Trophy,
  },
  {
    name: "Schedule & announcements",
    description:
      "A Firestore-backed schedule and announcement feed keeps the agenda and updates in one place.",
    benefit: "Participants always know what's happening next.",
    icon: CalendarClock,
  },
  {
    name: "Organiser control centre",
    description:
      "Admins create hackathons, set judging rules, manage criteria, assign judges, and track live counts.",
    benefit: "Running an event becomes a guided workflow instead of guesswork.",
    icon: Gauge,
  },
];

export const screenshots: Screenshot[] = [
  {
    title: "Organiser Dashboard",
    caption:
      "A live overview of participants, teams, submissions, and judges with quick actions for the day.",
    alt: "Persaka Hackathon App organiser dashboard showing live participant, team, submission, and judge counts inside a phone mock-up.",
    image: organiserDashboard,
    icon: Gauge,
  },
  {
    title: "Teams & Codes",
    caption:
      "Create a team to generate a shareable code, or join an existing team in one tap.",
    alt: "Persaka Hackathon App team directory showing team codes, members, and ownership details.",
    image: teamCode,
    icon: Users,
  },
  {
    title: "Submission Hub",
    caption:
      "Leaders submit repository and demo-video links with deadlines enforced automatically.",
    alt: "Persaka Hackathon App submission hub screen for leader teams and joined hackathons.",
    image: submissionHub,
    icon: ScrollText,
  },
  {
    title: "Judging & Rubric",
    caption:
      "Judges score assigned teams against shared rubric criteria, with optional anonymity.",
    alt: "Persaka Hackathon App team scoring screen with dynamic rubric sliders and judge comments.",
    image: teamScoring,
    icon: ClipboardCheck,
  },
  {
    title: "Live Leaderboard",
    caption:
      "Published standings and final results keep every team up to date in real time.",
    alt: "Persaka Hackathon App final results screen with podium and published standings.",
    image: leaderboard,
    icon: Trophy,
  },
];

export const benefits: Benefit[] = [
  {
    title: "Saves time",
    description:
      "One app replaces forms, spreadsheets, and chat threads, so organisers reclaim hours before and during the event.",
    icon: Gauge,
  },
  {
    title: "Keeps everyone organised",
    description:
      "Teams, submissions, schedule, and standings live in one structured place instead of scattered tools.",
    icon: Layers,
  },
  {
    title: "Simplifies judging",
    description:
      "Rubric-based scorecards and clear thresholds turn a stressful tally into a guided, repeatable process.",
    icon: ClipboardCheck,
  },
  {
    title: "Builds trust",
    description:
      "Consistent criteria, optional anonymous judging, and minimum-judge rules make results fair and defensible.",
    icon: ShieldCheck,
  },
  {
    title: "Keeps teams informed",
    description:
      "Live announcements, schedule, and leaderboard updates answer participants' questions before they ask.",
    icon: CalendarClock,
  },
  {
    title: "Works where people are",
    description:
      "A mobile-first Flutter experience on Android and iOS means the event runs from everyone's pocket.",
    icon: Smartphone,
  },
];

export const aboutPoints: { label: string; value: string }[] = [
  { label: "Built for", value: "Participants, judges & organisers" },
  { label: "Purpose", value: "End-to-end hackathon management" },
  { label: "Platform", value: "Flutter · Android & iOS" },
  { label: "Backend", value: "Firebase Auth & Cloud Firestore" },
];

export const team: TeamMember[] = [
  {
    name: "Tan Zheng Yu",
    role: "AI Engineer",
    responsibilities:
      "Leads AI-driven features and data workflows, and coordinates the project's technical direction.",
    image: tanZhengYu,
  },
  {
    name: "Muhammad Aiman Danish",
    role: "Backend Developer",
    responsibilities:
      "Designs the Firebase data model and Firestore rules powering auth, teams, judging, and results.",
    image: aiman,
  },
  {
    name: "Muhammad Aidil Haikal",
    role: "Mobile Developer",
    responsibilities:
      "Builds Flutter screens and flows for participants, teams, and the submission hub.",
    image: aidil,
  },
  {
    name: "Reem Omer",
    role: "Mobile Developer",
    responsibilities:
      "Implements judging, schedule, and leaderboard interfaces, focusing on usability and polish.",
    image: omer,
  },
];

export const contactEmail = "tanzhengyu@graduate.utm.my";

export const contactLinks: ContactLink[] = [
  {
    label: "Email us",
    value: contactEmail,
    href: `mailto:${contactEmail}?subject=Persaka%20Hackathon%20App%20Enquiry`,
    icon: Mail,
  },
  {
    label: "GitHub repository",
    value: "zhengyu89/persaka_hackathon_app",
    href: product.repository,
    icon: Github,
  },
];

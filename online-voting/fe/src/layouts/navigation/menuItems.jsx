import SvgColor from 'src/components/svg-color';
import { pastElections } from "src/utils/past-elections";

const icon = (name) => (
    <SvgColor src={`/assets/svg/${name}.svg`} sx={{ width: 1, height: 1 }} />
);

const politicalElectionsChildren = Object.keys(pastElections).sort((a, b) => a > b ? -1 : 1).map(year => ({
    id: "pastel" + year,
    title: year,
    type: "collapse",
    haschildren: true,
    children: Object.keys(pastElections[year]).map(electionType => {
        const hasMoreLevels = typeof pastElections[year][electionType] == "object";
        return {
            id: "pastel" + year + electionType,
            title: electionType,
            type: hasMoreLevels ? "collapse" : "item",
            haschildren: hasMoreLevels,
            path: hasMoreLevels ? "" : `/past-elections/${year}/${electionType}`,
            children: hasMoreLevels ?
                Object.keys(pastElections[year][electionType]).map((election, index) => ({
                    id: "pastel" + year + electionType + index,
                    title: typeof pastElections[year][electionType][election] == "object" ? pastElections[year][electionType][election].title : election,
                    type: "item",
                    path: `/past-elections/${year}/${electionType}/${election}`
                }))
                : []
        }
    })
}));

const menuItems = [
    {
        id: "pastelmenu",
        title: 'past elections',
        path: '/',
        icon: icon('past'),
        neutral: true,
        haschildren: true,
        type: "collapse",
        children: politicalElectionsChildren
    },
    {
        id: "yourvotesmenu",
        title: 'your votes',
        path: '/votes',
        icon: icon('vote2'),
        type: 'item',
        haschildren: false,
        mustBeLoggedInAndUser: true,
    },
    {
        id: "profilemenu",
        title: 'profile',
        path: '/profile',
        type: 'item',
        icon: icon('profile'),
        haschildren: false,
        mustBeLoggedIn: true
    },
    {
        id: "loginmenu",
        title: 'login',
        path: '/login',
        type: 'item',
        icon: icon('lock'),
        haschildren: false,
        mustBeLoggedOut: true
    }
];

const createMenuItems = (elections) => {
    const todayElectionsMenuItems = elections.today.length === 0 ? [] : [{
        id: "todaymenu",
        title: 'elections today',
        path: '/',
        icon: icon('today'),
        neutral: true,
        haschildren: true,
        type: "collapse",
        children: elections.today.map(election => ({
            id: "todaymenu" + election.type,
            title: election.type,
            type: 'item',
            path: `/elections-today/${election._id}`
        }))
    }];

    const futureElectionsByYear = [...new Set(elections.future.map(election => election.year))];
    const futureElectionsMenuItems = {
        id: "futuremenu",
        title: 'future elections',
        path: '/',
        icon: icon('future'),
        neutral: true,
        haschildren: true,
        type: "collapse",
        children: futureElectionsByYear.map(year => (
            {
                id: "futuremenu" + year,
                title: year,
                type: "collapse",
                haschildren: true,
                children: elections.future.filter(election => election.year === year).map(election => ({
                    id: "futuremenusub" + year + election.type,
                    title: election.type,
                    type: 'item',
                    url: ''
                }))
            }
        ))
    };

    return todayElectionsMenuItems.concat(menuItems);
}

export default createMenuItems;
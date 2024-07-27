import { map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { pureComponentHooks } from 'common/react';
import { Component, Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Chart, ColorBox, Flex, Icon, LabeledList, ProgressBar, Section, Table } from '../components';
import { NtosWindow, Window } from '../layouts';

const PEAK_DRAW = 500000;

const powerRank = str => {
  const unit = String(str.split(' ')[1]).toLowerCase();
  return ['w', 'kw', 'mw', 'gw'].indexOf(unit);
};


export const PowerMonitor = (props, context) => {
  const { data, act } = useBackend(context);
  const { history } = data;
  const supplyData = history.supply.map((value, i) => [i, value]);
  const demandData = history.demand.map((value, i) => [i, value]);

  const [sortByField, setSortByField] = useLocalState(context, 'sortby', null);

  const maxValue = Math.max(
    PEAK_DRAW,
    ...history.supply,
    ...history.demand);
    // Process area data

  const areas = flow([
    map((area, i) => ({
      ...area,
      // Generate a unique id
      id: area.name + i,
    })),
    sortByField === 'name' && sortBy(area => area.name),
    sortByField === 'charge' && sortBy(area => -area.charge),
    sortByField === 'draw' && sortBy(
      area => -powerRank(area.load),
      area => -parseFloat(area.load)),
  ])(data.areas);

  
  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <Flex spacing={1}>
          <Flex.Item width="200px">
            <Section>
              <SupplyDraw history={history} />
            </Section>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Section position="relative" height="100%">
              <Chart.Line
                fillPositionedParent
                data={supplyData}
                rangeX={[0, supplyData.length - 1]}
                rangeY={[0, maxValue]}
                strokeColor="rgba(0, 181, 173, 1)"
                fillColor="rgba(0, 181, 173, 0.25)" />
              <Chart.Line
                fillPositionedParent
                data={demandData}
                rangeX={[0, demandData.length - 1]}
                rangeY={[0, maxValue]}
                strokeColor="rgba(224, 57, 151, 1)"
                fillColor="rgba(224, 57, 151, 0.25)" />
            </Section>
          </Flex.Item>
        </Flex>
        <Section>
          <Box mb={1}>
            <Box inline mr={2} color="label">
              Sort by:
            </Box>
            <Button.Checkbox
              checked={sortByField === 'name'}
              content="Name"
              onClick={() => setSortByField('name')} />
            <Button.Checkbox
              checked={sortByField === 'charge'}
              content="Charge"
              onClick={() => setSortByField('charge')} />
            <Button.Checkbox
              checked={sortByField === 'draw'}
              content="Draw"
              onClick={() => setSortByField('draw')} />
          </Box>
          <Table>
            <Table.Row header>
              <Table.Cell>
                Area
              </Table.Cell>
              <Table.Cell collapsing>
                Charge
              </Table.Cell>
              <Table.Cell textAlign="right">
                Draw
              </Table.Cell>
              <Table.Cell collapsing title="Equipment">
                Eqp
              </Table.Cell>
              <Table.Cell collapsing title="Lighting">
                Lgt
              </Table.Cell>
              <Table.Cell collapsing title="Environment">
                Env
              </Table.Cell>
            </Table.Row>
            {areas.map((area, i) => (
              <tr
                key={area.id}
                className="Table__row candystripe">
                <td>
                  {area.name}
                </td>
                <td className="Table__cell text-right text-nowrap">
                  <AreaCharge
                    charging={area.charging}
                    charge={area.charge} />
                </td>
                <td className="Table__cell text-right text-nowrap">
                  {area.load}
                </td>
                <td className="Table__cell text-center text-nowrap">
                  <AreaStatusColorBox status={area.eqp} />
                </td>
                <td className="Table__cell text-center text-nowrap">
                  <AreaStatusColorBox status={area.lgt} />
                </td>
                <td className="Table__cell text-center text-nowrap">
                  <AreaStatusColorBox status={area.env} />
                </td>
              </tr>
            ))}
          </Table>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};


const SupplyDraw = (props, context) => {
  const { history } = props;
  const supply = history.supply[history.supply.length - 1] || 0;
  const demand = history.demand[history.demand.length - 1] || 0;
  
  const maxValue = Math.max(
    PEAK_DRAW,
    ...history.supply,
    ...history.demand);

  return (
    <LabeledList>
      <LabeledList.Item label="Supply">
        <ProgressBar
          value={supply}
          minValue={0}
          maxValue={maxValue}
          color="teal">
          {toFixed(supply / 1000)} kW
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Draw">
        <ProgressBar
          value={demand}
          minValue={0}
          maxValue={maxValue}
          color="pink"
          content>
          {toFixed(demand / 1000)} kW
        </ProgressBar>
      </LabeledList.Item>
    </LabeledList>
  );
};


const AreaCharge = (props, context) => {
  const { charging, charge } = props;
  return (
    <Fragment>
      <Icon
        width="18px"
        textAlign="center"
        name={(
          charging === 0 && (
            charge > 50
              ? 'battery-half'
              : 'battery-quarter'
          )
          || charging === 1 && 'bolt'
          || charging === 2 && 'battery-full'
        )}
        color={(
          charging === 0 && (
            charge > 50
              ? 'yellow'
              : 'red'
          )
          || charging === 1 && 'yellow'
          || charging === 2 && 'green'
        )} />
      <Box
        inline
        width="36px"
        textAlign="right">
        {toFixed(charge) + '%'}
      </Box>
    </Fragment>
  );
};

// AreaCharge.defaultHooks = pureComponentHooks;

const AreaStatusColorBox = (props, context) => {
  const { status } = props;
  const power = Boolean(status & 2);
  const mode = Boolean(status & 1);
  const tooltipText = (power ? 'On' : 'Off')
    + ` [${mode ? 'auto' : 'manual'}]`;
  return (
    <ColorBox
      color={power ? 'good' : 'bad'}
      content={mode ? undefined : 'M'}
      title={tooltipText} />
  );
};

// AreaStatusColorBox.defaultHooks = pureComponentHooks;
